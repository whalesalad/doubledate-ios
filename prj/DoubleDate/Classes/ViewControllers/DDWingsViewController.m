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
#import "DDFacebookFriendsViewController.h"
#import "DDUserTableViewCell.h"
#import "DDBarButtonItem.h"
#import "DDSegmentedControl.h"
#import "DDTableViewController+Refresh.h"

#define kTagMainLabel 1
#define kTagDetailedLabel 2
#define kTagPhoto 3
#define kTagConfirmDeleteFriendshipAlert 4
#define kTagConfirmDeleteFriendAlert 5
#define kTagActionSheetInvite 6

@interface DDWingsViewControllerAlertView : UIAlertView
@property(nonatomic, retain) DDShortUser *shortUser;
@property(nonatomic, retain) DDFriendship *friendship;
@end

@implementation DDWingsViewControllerAlertView

@synthesize shortUser;
@synthesize friendship;

- (void)dealloc
{
    [shortUser release];
    [friendship release];
    [super dealloc];
}

@end

@interface DDWingsViewControllerTableViewCell : DDUserTableViewCell

@property(nonatomic, retain) DDFriendship *friendship;

@end

@implementation DDWingsViewControllerTableViewCell

@synthesize friendship;

- (void)dealloc
{
    [friendship release];
    [super dealloc];
}

@end

@interface DDWingsViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>

- (void)onDataRefreshed;
- (BOOL)isWingsMode;
- (BOOL)isInvitationsMode;
- (void)updateSegmentedControl;
- (void)updateNavigationButtons;
- (void)inviteBySms;
- (void)inviteByFacebook;

@end

@implementation DDWingsViewController

@synthesize user;
@synthesize delegate;
@synthesize isSelectingMode;

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
    self.navigationItem.title = NSLocalizedString(@"Wings", nil);
    
    //remove search bar
    self.tableView.tableHeaderView = nil;
    
    //update segmented controler
    [self updateSegmentedControl];
    
    //update navigation buttons
    [self updateNavigationButtons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check if we need to make a request
    if (!friends_ && !pendingInvitations_)
        [self startRefreshWithText:NSLocalizedString(@"Loading", nil)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [user release];
    [friends_ release];
    [pendingInvitations_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

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
        if (![self.navigationItem.titleView isKindOfClass:[UISegmentedControl class]])
        {
            NSArray *items = [NSArray arrayWithObjects:NSLocalizedString(@"Wings", nil), NSLocalizedString(@"Incoming", nil), nil];
            UISegmentedControl *segmentedControl = [[[DDSegmentedControl alloc] initWithItems:items] autorelease];
            segmentedControl.selectedSegmentIndex = 0;
            [segmentedControl addTarget:self action:@selector(tabChanged:) forControlEvents:UIControlEventValueChanged];
            self.navigationItem.titleView = segmentedControl;
        }
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
    else if (self.isSelectingMode)
    {
        //add back button
        self.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Cancel", nil) target:self action:@selector(cancelTouched:)];
    }
    else
    {
        //add left button
        self.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"dd-button-add-icon.png"] target:self action:@selector(plusTouched:)];
        
        //add right button
        self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Edit", nil) target:self action:@selector(editTouched:)];
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

- (void)onDataRefreshed
{
    //check both data received
    if (friends_ && pendingInvitations_)
    {
        //hide loading
        [self finishRefresh];
    
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
    //check facebook user
    if (user.facebookId)
    {
        UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"By SMS / iMessage", nil), NSLocalizedString(@"From Facebook Friends", nil), nil] autorelease];
        sheet.tag = kTagActionSheetInvite;
        [sheet showFromTabBar:self.tabBarController.tabBar];
    }
    else
    {
        UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"By SMS / iMessage", nil), nil] autorelease];
        sheet.tag = kTagActionSheetInvite;
        [sheet showFromTabBar:self.tabBarController.tabBar];
    }
}

- (void)editTouched:(id)sender
{
    //update editing mode
    if ([self isWingsMode])
        self.tableView.editing = !self.tableView.editing;
    
    //set right button
    if (self.tableView.editing)
        self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Done", nil) target:self action:@selector(editTouched:)];
    else
        self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Edit", nil) target:self action:@selector(editTouched:)];
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
        alertView.shortUser = cell.shortUser;
        alertView.friendship = cell.friendship;
        [alertView show];
    }
}

- (void)cancelTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)inviteBySms
{
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *messageComposer = [[[MFMessageComposeViewController alloc] init] autorelease];
        messageComposer.messageComposeDelegate = self;
        messageComposer.body = [NSString stringWithFormat:@"Become my wing on DoubleDate! %@%@", [DDTools serverUrlPath], user.invitePath];
        [self.navigationController presentViewController:messageComposer animated:YES completion:^{
        }];
    }
    else
    {
        //show error
        [[[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"You are not able to send text messages", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
    }
}

- (void)inviteByFacebook
{
    DDFacebookFriendsViewController *viewController = [[[DDFacebookFriendsViewController alloc] init] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DDWingsViewControllerTableViewCell height];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check if we need expand
    if (!self.isSelectingMode)
    {
        //show hud
        [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
        
        //get cell
        DDUserTableViewCell *wingsTableViewCell = (DDUserTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath];
        
        //request information about user
        [self.apiController getFriend:wingsTableViewCell.shortUser];
        
        //deselect row
        [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    }

    //inform delegate about selecting
    [self.delegate wingsViewController:self didSelectUser:[(DDUserTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath] shortUser]];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (BOOL)tableView:(UITableView *)aTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self isWingsMode];
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //get cell
        DDUserTableViewCell *wingsTableViewCell = (DDUserTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath];
        if ([wingsTableViewCell isKindOfClass:[DDUserTableViewCell class]])
        {
            //generate message
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Are you sure that you would like to remove %@ from your wings?", nil) , wingsTableViewCell.shortUser.fullName];
            
            //create alert
            DDWingsViewControllerAlertView *alertView = [[[DDWingsViewControllerAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Yes, Remove", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil] autorelease];
            alertView.tag = kTagConfirmDeleteFriendAlert;
            alertView.shortUser = wingsTableViewCell.shortUser;
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
    NSString *cellIdentifier = [[DDWingsViewControllerTableViewCell class] description];
    
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
        tableViewCell.type = DDUserTableViewCellTypeWings;
        friend = [friends_ objectAtIndex:indexPath.row];
        
        if (!self.isSelectingMode)
        {
            UIImage *normalArrow = [UIImage imageNamed:@"grey-detail-arrow.png"];
            UIImage *selectedArrow = [UIImage imageNamed:@"grey-detail-arrow.png"];
            
            UIButton *accessoryView = [UIButton buttonWithType:UIButtonTypeCustom];
            accessoryView.frame = CGRectMake(0.0f, 0.0f, normalArrow.size.width, normalArrow.size.height);
            accessoryView.userInteractionEnabled = NO;
            [accessoryView setImage:normalArrow forState:UIControlStateNormal];
            [accessoryView setImage:selectedArrow forState:UIControlStateHighlighted];
            tableViewCell.accessoryView = accessoryView;
        }
    }
    else if ([self isInvitationsMode])
    {
        tableViewCell.type = DDUserTableViewCellTypeInvitations;
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
    }
    
    //save data
    [tableViewCell setShortUser:friend];
    [tableViewCell setFriendship:friendship];
    
    //update layouts
    [tableViewCell setNeedsLayout];
    
    return tableViewCell;
}

#pragma mark -
#pragma mark API

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
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)requestDenyFriendshipSucceed
{
}

- (void)requestDenyFriendshipDidFailedWithError:(NSError*)error
{
    //reload data
    [self startRefreshWithText:NSLocalizedString(@"Loading", nil)];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)requestDeleteFriendSucceed
{
}

- (void)requestDeleteFriendDidFailedWithError:(NSError*)error
{
    //reload data
    [self startRefreshWithText:NSLocalizedString(@"Loading", nil)];
    
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
    meViewController.backButtonTitle = NSLocalizedString(@"WINGS", nil);
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
#pragma mark UIAlertViewDelegate

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
            DDShortUser *shortuser = [wingsAlertView.shortUser retain];
            
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
#pragma mark UIActionSheetDelegate

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
#pragma mark -

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark -
#pragma mark -

- (void)onRefresh
{
    //unset old values
    [friends_ release];
    friends_ = nil;
    [pendingInvitations_ release];
    pendingInvitations_ = nil;
    
    //request friends
    [self.apiController getFriends];
    
    //request friendship invitations
    [self.apiController getFriendshipInvitations];
}

@end
