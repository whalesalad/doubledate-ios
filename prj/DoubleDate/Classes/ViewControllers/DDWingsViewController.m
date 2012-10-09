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
#import <QuartzCore/QuartzCore.h>

#define kTagMainLabel 1
#define kTagDetailedLabel 2
#define kTagPhoto 3
#define kTagConfirmDeleteAlert 4

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

@interface DDWingsViewController () <UITableViewDataSource, UITableViewDelegate>

- (void)reloadData:(BOOL)animated;
- (void)onDataReloaded;
- (BOOL)isWingsMode;
- (BOOL)isInvitationsMode;
- (void)updateSegmentedControl;
- (void)updateNavigationButtons;

@end

@implementation DDWingsViewController

@synthesize tableView;

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
        [self reloadData:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [tableView release];
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
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"+", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(plusTouched:)] autorelease];
        
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

- (void)reloadData:(BOOL)animated
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

- (void)onDataReloaded
{
    //check both data received
    if (friends_ && pendingInvitations_)
    {
        //hide hud
        [self hideHud:YES];
    
        //reload the table
        [self.tableView reloadData];
        
        //update segmented control
        [self updateSegmentedControl];
    }
}

- (void)plusTouched:(id)sender
{
    
}

- (void)editTouched:(id)sender
{
    if ([self isWingsMode])
        self.tableView.editing = !self.tableView.editing;
}

- (void)tabChanged:(id)sender
{
    //unset editing
    self.tableView.editing = NO;
    
    //reload the table
    [self.tableView reloadData];
    
    //update navigation buttons
    [self updateNavigationButtons];
}

- (void)inviteTouched:(UIButton*)sender
{
    DDWingsViewControllerTableViewCell *cell = (DDWingsViewControllerTableViewCell*)sender.superview.superview;
    if ([cell isKindOfClass:[DDWingsViewControllerTableViewCell class]])
    {
        //show hud
        [self showHudWithText:NSLocalizedString(@"Updating", nil) animated:YES];
        
        //update invite
        [self.apiController requestApproveFriendship:cell.friendship];
    }
}

- (void)denyTouched:(UIButton*)sender
{
    DDWingsViewControllerTableViewCell *cell = (DDWingsViewControllerTableViewCell*)sender.superview.superview;
    if ([cell isKindOfClass:[DDWingsViewControllerTableViewCell class]])
    {
        DDWingsViewControllerAlertView *alertView = [[[DDWingsViewControllerAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Are you sure you want to ignore this invitation?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Yes, Ignore", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil] autorelease];
        alertView.tag = kTagConfirmDeleteAlert;
        alertView.shortuser = cell.shortuser;
        alertView.friendship = cell.friendship;
        [alertView show];
    }
}

#pragma mark -
#pragma comment UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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
            //show hud
            [self showHudWithText:NSLocalizedString(@"Updating", nil) animated:YES];
            
            //delete friend
            [self.apiController requestDeleteFriend:wingsTableViewCell.shortuser];
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
        friend = friendship.friendUser;
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
        tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        label.font = [UIFont systemFontOfSize:13];
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
    [[tableViewCell.contentView viewWithTag:kTagPhoto] setFrame:CGRectMake(5, 5, 40, 40)];
    if ([self isWingsMode])
    {
        [[tableViewCell.contentView viewWithTag:kTagMainLabel] setFrame:CGRectMake(55, 2, 225, 28)];
        [[tableViewCell.contentView viewWithTag:kTagDetailedLabel] setFrame:CGRectMake(55, 32, 225, 15)];
    }
    else if ([self isInvitationsMode])
    {
        [[tableViewCell.contentView viewWithTag:kTagMainLabel] setFrame:CGRectMake(55, 2, 195, 28)];
        [[tableViewCell.contentView viewWithTag:kTagDetailedLabel] setFrame:CGRectMake(55, 32, 195, 15)];
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
    friends_ = [friends retain];
    
    //inform about reloaded data
    [self onDataReloaded];
}

- (void)getFriendsDidFailedWithError:(NSError*)error
{
    //save friends
    [friends_ release];
    friends_ = [[NSArray alloc] init];
    
    //inform about reloaded data
    [self onDataReloaded];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)getFriendshipInvitationsSucceed:(NSArray*)invitations
{
    //save invitations
    [pendingInvitations_ release];
    pendingInvitations_ = [invitations retain];
    
    //inform about reloaded data
    [self onDataReloaded];
}

- (void)getFriendshipInvitationsDidFailedWithError:(NSError*)error
{
    //save friendship invitations
    [pendingInvitations_ release];
    pendingInvitations_ = [[NSArray alloc] init];
    
    //inform about reloaded data
    [self onDataReloaded];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)requestApproveFriendshipSucceed:(DDFriendship*)friendship
{
    //reload data
    [self reloadData:NO];
}

- (void)requestApproveFriendshipDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)requestDenyFriendshipSucceed
{
    //reload data
    [self reloadData:NO];
}

- (void)requestDenyFriendshipDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)requestDeleteFriendSucceed
{
    //reload data
    [self reloadData:NO];
}

- (void)requestDeleteFriendDidFailedWithError:(NSError*)error
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
    if ([alertView isKindOfClass:[DDWingsViewControllerAlertView class]] && alertView.tag == kTagConfirmDeleteAlert)
    {
        DDWingsViewControllerAlertView *wingsAlertView = (DDWingsViewControllerAlertView*)alertView;
        if (buttonIndex == 0)
        {
            //show hud
            [self showHudWithText:NSLocalizedString(@"Updating", nil) animated:YES];
            
            //send request
            [self.apiController requestDenyFriendship:wingsAlertView.friendship];
        }
    }
}

@end
