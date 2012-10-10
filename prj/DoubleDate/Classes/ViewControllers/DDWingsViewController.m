//
//  DDWingsViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 08.10.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDWingsViewController.h"
#import "DDAPIController.h"
#import "DDUser.h"
#import "DDFriendship.h"
#import "DDImageView.h"
#import "DDMeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "DDTools.h"

#define kTagMainLabel 1
#define kTagDetailedLabel 2
#define kTagPhoto 3
#define kTagConfirmDeleteFriendshipAlert 4
#define kTagConfirmDeleteFriendAlert 5
#define kTagActionSheetInvite 6

@interface DDWingsViewControllerAlertView : UIAlertView
@property(nonatomic, retain) DDShortUser *shortuser;
@property(nonatomic, retain) DDFriendship *friendship;
@end

@implementation DDWingsViewControllerAlertView

@synthesize shortuser;
@synthesize friendship;

- (void)dealloc
{
    [shortuser release];
    [friendship release];
    [super dealloc];
}

@end

@interface DDWingsViewControllerTableViewCell : UITableViewCell
@property(nonatomic, retain) DDShortUser *shortuser;
@property(nonatomic, retain) DDFriendship *friendship;
@end

@implementation DDWingsViewControllerTableViewCell

@synthesize shortuser;
@synthesize friendship;

- (void)dealloc
{
    [shortuser release];
    [friendship release];
    [super dealloc];
}

@end

@interface DDWingsViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>

- (void)refresh:(BOOL)animated;
- (void)onDataRefreshed;
- (BOOL)isWingsMode;
- (BOOL)isInvitationsMode;
- (void)updateSegmentedControl;
- (void)updateNavigationButtons;
- (void)inviteBySms;
- (void)inviteByFacebook;

@end

@implementation DDWingsViewController

@synthesize tableView;
@synthesize user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Location", nil);
    
    //update segmented controler
    [self updateSegmentedControl];
    
    //update navigation buttons
    [self updateNavigationButtons];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [tableView release], tableView = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check if we need to make a request
    if (!friends_ && !pendingInvitations_)
        [self refresh:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [tableView release];
    [user release];
    [friends_ release];
    [pendingInvitations_ release];
    [super dealloc];
}

#pragma mark -
#pragma comment other

- (UISegmentedControl*)segmentedControl
{
    if ([self.navigationItem.titleView isKindOfClass:[UISegmentedControl class]])
        return (UISegmentedControl*)self.navigationItem.titleView;
    return nil;
}

- (void)updateSegmentedControl
{
    //check for exist invitation
    if ([pendingInvitations_ count])
    {
        //add segmented control
        NSArray *items = [NSArray arrayWithObjects:NSLocalizedString(@"Wings", nil), NSLocalizedString(@"Incoming", nil), nil];
        UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc] initWithItems:items] autorelease];
        segmentedControl.selectedSegmentIndex = 0;
        segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        [segmentedControl addTarget:self action:@selector(tabChanged:) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = segmentedControl;
    }
    else
    {
        self.navigationItem.titleView = nil;
        self.navigationItem.title = NSLocalizedString(@"Wings", nil);
    }
}

- (void)updateNavigationButtons
{
    if ([self segmentedControl] && [[self segmentedControl] selectedSegmentIndex] == 1)
    {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        //add left button
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(plusTouched:)] autorelease];
        
        //add right button
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(editTouched:)] autorelease];
    }
}

- (BOOL)isWingsMode
{
    return [[self segmentedControl] selectedSegmentIndex] == 0;
}

- (BOOL)isInvitationsMode
{
    return [[self segmentedControl] selectedSegmentIndex] == 1;
}

- (void)refresh:(BOOL)animated
{
    //unset old values
    [friends_ release];
    friends_ = nil;
    [pendingInvitations_ release];
    pendingInvitations_ = nil;
    
    //show hud
    [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:animated];
    
    //request friends
    [self.apiController getFriends];
    
    //request friendship invitations
    [self.apiController getFriendshipInvitations];
}

- (void)onDataRefreshed
{
    //check both data received
    if (friends_ && pendingInvitations_)
    {
        //hide hud
        [self hideHud:YES];
    
        //update segmented control
        [self updateSegmentedControl];
        
        //update navgation buttons
        [self updateNavigationButtons];
        
        //reload the table
        [self.tableView reloadData];
    }
}

- (void)plusTouched:(id)sender
{
    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"By SMS / iMessage", nil), NSLocalizedString(@"From Facebook Friends", nil), nil] autorelease];
    sheet.tag = kTagActionSheetInvite;
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)editTouched:(id)sender
{
    if ([self isWingsMode])
        self.tableView.editing = !self.tableView.editing;
}

- (void)tabChanged:(UISegmentedControl*)sender
{
    //unset editing
    self.tableView.editing = NO;
    
    //reload the table
    [self.tableView reloadData];
    
    //update navigation buttons
    [self updateNavigationButtons];
    
    //update title
    self.navigationItem.title = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
}

- (void)inviteTouched:(UIButton*)sender
{
    DDWingsViewControllerTableViewCell *cell = (DDWingsViewControllerTableViewCell*)sender.superview.superview;
    if ([cell isKindOfClass:[DDWingsViewControllerTableViewCell class]])
    {
        //save friendship
        DDFriendship *friendship = [cell.friendship retain];
        
        //move friend from friendship
        [friends_ addObject:friendship.user];
        [pendingInvitations_ removeObject:friendship];

        //check if no ivites anymore
        if ([pendingInvitations_ count] == 0)
        {
            //update segmented control
            [self updateSegmentedControl];
            
            //update navigation buttons
            [self updateNavigationButtons];
        }
        
        //reload the table
        [self.tableView reloadData];
        
        //update invite
        [self.apiController requestApproveFriendship:friendship];
        
        //release friendship
        [friendship release];
    }
}

- (void)denyTouched:(UIButton*)sender
{
    DDWingsViewControllerTableViewCell *cell = (DDWingsViewControllerTableViewCell*)sender.superview.superview;
    if ([cell isKindOfClass:[DDWingsViewControllerTableViewCell class]])
    {
        DDWingsViewControllerAlertView *alertView = [[[DDWingsViewControllerAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Are you sure you want to ignore this invitation?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Yes, Ignore", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil] autorelease];
        alertView.tag = kTagConfirmDeleteFriendshipAlert;
        alertView.shortuser = cell.shortuser;
        alertView.friendship = cell.friendship;
        [alertView show];
    }
}

- (void)inviteBySms
{
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *messageComposer = [[[MFMessageComposeViewController alloc] init] autorelease];
        messageComposer.messageComposeDelegate = self;
        messageComposer.body = [NSString stringWithFormat:@"Become my wing on DoubleDate! %@%@", [DDTools serverUrlPath], user.invitePath];
        [self.navigationController presentModalViewController:messageComposer animated:YES];
    }
    else
    {
        //show error
        [[[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"You are not able to send text messages", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
    }
}

- (void)inviteByFacebook
{
    
}

#pragma mark -
#pragma comment UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
    
    //get cell
    DDWingsViewControllerTableViewCell *wingsTableViewCell = (DDWingsViewControllerTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath];
    
    //request information about user
    [self.apiController getFriend:wingsTableViewCell.shortuser];
    
    //deselect row
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma comment UITableViewDataSource

- (BOOL)tableView:(UITableView *)aTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self isWingsMode];
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //get cell
        DDWingsViewControllerTableViewCell *wingsTableViewCell = (DDWingsViewControllerTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath];
        if ([wingsTableViewCell isKindOfClass:[DDWingsViewControllerTableViewCell class]])
        {
            //generate message
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Are you sure that you would like to remove %@ from your wings?", nil) , wingsTableViewCell.shortuser.fullName];
            
            //create alert
            DDWingsViewControllerAlertView *alertView = [[[DDWingsViewControllerAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Yes, Remove", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil] autorelease];
            alertView.tag = kTagConfirmDeleteFriendAlert;
            alertView.shortuser = wingsTableViewCell.shortuser;
            [alertView show];
        }
    }
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if ([self isWingsMode])
        return [friends_ count];
    else if ([self isInvitationsMode])
        return [pendingInvitations_ count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set identifier
    NSString *cellIdentifier = @"DDWingsControllerTableViewCell";
    
    //create cell if needed
    DDWingsViewControllerTableViewCell *tableViewCell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!tableViewCell)
        tableViewCell = [[[DDWingsViewControllerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    
    //unset friend
    DDShortUser *friend = nil;
    DDFriendship *friendship = nil;
        
    //check for wings
    if ([self isWingsMode])
    {
        friend = [friends_ objectAtIndex:indexPath.row];
        tableViewCell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure-arrow.png"]] autorelease];
        tableViewCell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else if ([self isInvitationsMode])
    {
        friendship = [pendingInvitations_ objectAtIndex:indexPath.row];
        friend = friendship.user;
        UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 44)] autorelease];
        UIButton *buttonInvite = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonInvite setImage:[UIImage imageNamed:@"approve-invite.png"] forState:UIControlStateNormal];
        buttonInvite.frame = CGRectMake(7, 9, 25, 25);
        [view addSubview:buttonInvite];
        [buttonInvite addTarget:self action:@selector(inviteTouched:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *buttonRemove = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonRemove setImage:[UIImage imageNamed:@"deny-invite.png"] forState:UIControlStateNormal];
        buttonRemove.frame = CGRectMake(37, 9, 25, 25);
        [view addSubview:buttonRemove];
        [buttonRemove addTarget:self action:@selector(denyTouched:) forControlEvents:UIControlEventTouchUpInside];
        tableViewCell.accessoryView = view;
        tableViewCell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    //check for main label
    if (![tableViewCell.contentView viewWithTag:kTagMainLabel])
    {
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        label.font = [UIFont boldSystemFontOfSize:16];
        label.tag = kTagMainLabel;
        label.backgroundColor = [UIColor clearColor];
        [tableViewCell.contentView addSubview:label];
    }
    
    //check for detailed label
    if (![tableViewCell.contentView viewWithTag:kTagDetailedLabel])
    {
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor grayColor];
        label.tag = kTagDetailedLabel;
        label.backgroundColor = [UIColor clearColor];
        [tableViewCell.contentView addSubview:label];
    }
    
    //check for photo
    if (![tableViewCell.contentView viewWithTag:kTagPhoto])
    {
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user-photo-overlay.png"]] autorelease];
        imageView.tag = kTagPhoto;
        imageView.backgroundColor = [UIColor clearColor];
        [tableViewCell.contentView addSubview:imageView];
    }
    
    //check for correct geometry
    [[tableViewCell.contentView viewWithTag:kTagPhoto] setFrame:CGRectMake(10, 5, 40, 40)];
    
    if ([self isWingsMode])
    {
        [[tableViewCell.contentView viewWithTag:kTagMainLabel] setFrame:CGRectMake(60, 6, 225, 22)];
        [[tableViewCell.contentView viewWithTag:kTagDetailedLabel] setFrame:CGRectMake(60, 28, 225, 15)];
    }
    else if ([self isInvitationsMode])
    {
        [[tableViewCell.contentView viewWithTag:kTagMainLabel] setFrame:CGRectMake(60, 2, 195, 28)];
        [[tableViewCell.contentView viewWithTag:kTagDetailedLabel] setFrame:CGRectMake(60, 32, 195, 15)];
    }
    
    //check friend
    if (friend)
    {
        //show all
        [[tableViewCell.contentView viewWithTag:kTagMainLabel] setHidden:NO];
        [[tableViewCell.contentView viewWithTag:kTagDetailedLabel] setHidden:NO];
        [[tableViewCell.contentView viewWithTag:kTagPhoto] setHidden:NO];
        
        //set text
        NSString *mainText = friend.fullName;
        [(UILabel*)[tableViewCell.contentView viewWithTag:kTagMainLabel] setText:mainText];
        
        //set text
        NSMutableString *detailedText = [NSMutableString string];
        if (friend.age)
        {
            [detailedText appendFormat:@"%dM", [friend.age intValue]];
            if (friend.location)
                [detailedText appendString:@", "];
        }
        if (friend.location)
            [detailedText appendString:friend.location];
        [(UILabel*)[tableViewCell.contentView viewWithTag:kTagDetailedLabel] setText:detailedText];
        
        //set photo
        UIImageView *photoView = (UIImageView*)[tableViewCell.contentView viewWithTag:kTagPhoto];
        while ([[photoView subviews] count])
            [[[photoView subviews] lastObject] removeFromSuperview];
        if (friend.photo.downloadUrl)
        {
            //set image view
            DDImageView *imageView = [[[DDImageView alloc] initWithFrame:CGRectMake(0, 0, photoView.frame.size.width-1, photoView.frame.size.height-1)] autorelease];
            imageView.layer.cornerRadius = 19;
            imageView.layer.masksToBounds = YES;
            [imageView reloadFromUrl:[NSURL URLWithString:friend.photo.downloadUrl]];
            [photoView addSubview:imageView];
        }
    }
    else
    {
        //hide all
        [[tableViewCell.contentView viewWithTag:kTagMainLabel] setHidden:YES];
        [[tableViewCell.contentView viewWithTag:kTagDetailedLabel] setHidden:YES];
        [[tableViewCell.contentView viewWithTag:kTagPhoto] setHidden:YES];
    }
    
    //save data
    [(DDWingsViewControllerTableViewCell*)tableViewCell setShortuser:friend];
    [(DDWingsViewControllerTableViewCell*)tableViewCell setFriendship:friendship];
    
    return tableViewCell;
}

#pragma mark -
#pragma comment API

- (void)getFriendsSucceed:(NSArray*)friends
{
    //save friends
    [friends_ release];
    friends_ = [[NSMutableArray arrayWithArray:friends] retain];
    
    //inform about reloaded data
    [self onDataRefreshed];
}

- (void)getFriendsDidFailedWithError:(NSError*)error
{
    //save friends
    [friends_ release];
    friends_ = [[NSMutableArray alloc] init];
    
    //inform about reloaded data
    [self onDataRefreshed];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)getFriendshipInvitationsSucceed:(NSArray*)invitations
{
    //save invitations
    [pendingInvitations_ release];
    pendingInvitations_ = [[NSMutableArray arrayWithArray:invitations] retain];
    
    //inform about reloaded data
    [self onDataRefreshed];
}

- (void)getFriendshipInvitationsDidFailedWithError:(NSError*)error
{
    //save friendship invitations
    [pendingInvitations_ release];
    pendingInvitations_ = [[NSMutableArray alloc] init];
    
    //inform about reloaded data
    [self onDataRefreshed];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)requestApproveFriendshipSucceed:(DDFriendship*)friendship
{
}

- (void)requestApproveFriendshipDidFailedWithError:(NSError*)error
{
    //reload data
    [self refresh:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)requestDenyFriendshipSucceed
{
}

- (void)requestDenyFriendshipDidFailedWithError:(NSError*)error
{
    //reload data
    [self refresh:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)requestDeleteFriendSucceed
{
}

- (void)requestDeleteFriendDidFailedWithError:(NSError*)error
{
    //reload data
    [self refresh:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)getFriendSucceed:(DDUser*)friend
{
    //hide hud
    [self hideHud:YES];
    
    //add view controller
    DDMeViewController *meViewController = [[[DDMeViewController alloc] init] autorelease];
    meViewController.user = friend;
    [self.navigationController pushViewController:meViewController animated:YES];
}

- (void)getFriendDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma comment UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isKindOfClass:[DDWingsViewControllerAlertView class]] && alertView.tag == kTagConfirmDeleteFriendshipAlert)
    {
        DDWingsViewControllerAlertView *wingsAlertView = (DDWingsViewControllerAlertView*)alertView;
        if (buttonIndex == 0)
        {
            //save friendship
            DDFriendship *fiendship = [wingsAlertView.friendship retain];
            
            //remove silent
            [pendingInvitations_ removeObject:fiendship];
            
            //check if no ivites anymore
            if ([pendingInvitations_ count] == 0)
            {
                //update segmented control
                [self updateSegmentedControl];
                
                //update navigation buttons
                [self updateNavigationButtons];
            }
            
            //reload the table
            [self.tableView reloadData];
            
            //send request
            [self.apiController requestDenyFriendship:fiendship];
            
            //release friendship
            [fiendship release];
        }
    }
    else if ([alertView isKindOfClass:[DDWingsViewControllerAlertView class]] && alertView.tag == kTagConfirmDeleteFriendAlert)
    {
        DDWingsViewControllerAlertView *wingsAlertView = (DDWingsViewControllerAlertView*)alertView;
        if (buttonIndex == 0)
        {
            //save user
            DDShortUser *shortuser = [wingsAlertView.shortuser retain];
            
            //remove silent
            [friends_ removeObject:shortuser];
            
            //reload the tanle
            [self.tableView reloadData];
            
            //send request
            [self.apiController requestDeleteFriend:shortuser];
            
            //release user
            [shortuser release];
        }
    }
}

#pragma mark -
#pragma comment UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kTagActionSheetInvite)
    {
        if (buttonIndex != actionSheet.cancelButtonIndex)
        {
            switch (buttonIndex) {
                case 0:
                    [self inviteBySms];
                    break;
                case 1:
                    [self inviteByFacebook];
                    break;
                default:
                    break;
            }
        }
    }
}

#pragma mark -
#pragma comment -

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

@end
