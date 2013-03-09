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
#import "DDImageView.h"
#import "DDMeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "DDTools.h"
#import "DDFacebookFriendsViewController.h"
#import "DDWingTableViewCell.h"
#import "DDBarButtonItem.h"
#import "DDSegmentedControl.h"
#import "DDTableViewController+Refresh.h"
#import "DDWingTableViewCell.h"
#import "DDInvitationTableViewCell.h"
#import "DDShortUser.h"
#import "DDAuthenticationController.h"
#import "DDUser.h"
#import "DDAppDelegate.h"
#import "UIView+Other.h"
#import "DDObjectsController.h"

#define kTagMainLabel 1
#define kTagDetailedLabel 2
#define kTagPhoto 3
#define kTagConfirmDeleteFriendshipAlert 4
#define kTagConfirmDeleteFriendAlert 5
#define kTagActionSheetInvite 6

#define kMoneyForFriend 10

@interface DDWingsViewControllerAlertView : UIAlertView
@property(nonatomic, retain) DDShortUser *shortUser;
@end

@implementation DDWingsViewControllerAlertView

@synthesize shortUser;

- (void)dealloc
{
    [shortUser release];
    [super dealloc];
}

@end

@interface DDWingsViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>

- (void)onDataRefreshed;
- (void)inviteBySms;
- (void)inviteByFacebook;
- (NSArray*)pendingInvitations;
- (NSArray*)wings;

@end

@implementation DDWingsViewController

@synthesize delegate;
@synthesize isSelectingMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectUpdatedNotification:) name:DDObjectsControllerDidUpdateObjectNotification object:nil];

    }
    return self;
}

- (void)customizeNoDataView
{
    [self.viewNoData applyNoDataWithImage:[UIImage imageNamed:@"no-wings.png"] title:NSLocalizedString(@"Add some of your closest\nfriends to get started", nil) addButtonTitle:NSLocalizedString(@"Add a Wing", nil) addButtonTarget:self addButtonAction:@selector(plusTouched:) addButtonEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 0) detailed:[NSString stringWithFormat:NSLocalizedString(@"For each friend you add,\nyou'll both earn %d coins!", nil), kMoneyForFriend]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Wings", nil);
    
    //add right button
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"dd-button-add-icon.png"] target:self action:@selector(plusTouched:)];
    
    // Add slight padding to end of view.
    self.tableView.contentInset = UIEdgeInsetsMake(0,0,3,0);
    
    //set placeholder for search bar
    [[self searchBar] setPlaceholder:NSLocalizedString(@"Search Wings", nil)];
    
    //customize no data view
    [self customizeNoDataView];
}

- (void)applyNoDataLabelStyle:(UILabel*)label {
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    label.textColor = [UIColor colorWithRed:93.0f/255.0f green:93.0f/255.0f blue:93.0f/255.0f alpha:1.0];
    label.layer.shadowOffset = CGSizeMake(0, 1);
    label.layer.shadowOpacity = 1.0f;
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowRadius = 1;
    label.layer.masksToBounds = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check if we need to make a request
    if (!friends_)
        [self startRefreshWithText:NSLocalizedString(@"Loading", nil)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [friends_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (BOOL)isUserExistInSearch:(DDShortUser*)shortUser
{
    BOOL existInSearch = [self.searchTerm length] == 0;
    if (self.searchTerm)
    {
        if (shortUser.name && [shortUser.name rangeOfString:self.searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)
            existInSearch = YES;
        if (shortUser.fullName && [shortUser.fullName rangeOfString:self.searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)
            existInSearch = YES;
        if (shortUser.firstName && [shortUser.firstName rangeOfString:self.searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)
            existInSearch = YES;
    }
    return existInSearch;
}

- (NSArray*)pendingInvitations
{
    NSMutableArray *ret = [NSMutableArray array];
    for (DDShortUser *shortUser in friends_)
    {
        if (![shortUser.approved boolValue] && [self isUserExistInSearch:shortUser])
            [ret addObject:shortUser];
    }
    return ret;
}

- (NSArray*)wings
{
    NSMutableArray *ret = [NSMutableArray array];
    for (DDShortUser *shortUser in friends_)
    {
        if ([shortUser.approved boolValue] && [self isUserExistInSearch:shortUser])
            [ret addObject:shortUser];
    }
    return ret;
}

- (void)onDataRefreshed
{
    //check both data received
    if (![self.apiController isRequestExist:friendsRequest_])
    {
        //hide loading
        [self finishRefresh];
        
        //reload the table
        [self.tableView reloadData];
        
        //update no messages
        [self updateNoDataView];
    }
}

- (void)plusTouched:(id)sender
{
    //check facebook user
    if ([DDAuthenticationController currentUser].facebookId)
    {
        UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Add a Wing", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SMS / iMessage", nil), NSLocalizedString(@"Facebook Friends", nil), nil] autorelease];
        sheet.tag = kTagActionSheetInvite;
        [sheet showInView:self.view];
    }
    else
    {
        UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Add a Wing", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SMS / iMessage", nil), nil] autorelease];
        sheet.tag = kTagActionSheetInvite;
        [sheet showInView:self.view];
    }
}

- (void)inviteTouched:(UIButton*)sender
{
    DDInvitationTableViewCell *cell = (DDInvitationTableViewCell*)sender.superview;
    if ([cell isKindOfClass:[DDInvitationTableViewCell class]])
    {
        //save friendship
        DDShortUser *friend = cell.shortUser;
        
        //move friend from friendship
        friend.approved = [NSNumber numberWithBool:YES];
        
        //unset number of unread wings
        [DDAuthenticationController currentUser].pendingWingsCount = [NSNumber numberWithInt:[[self pendingInvitations] count]];
        
        //update application badge
        [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] updateApplicationBadge];
        
        //reload the table
        [self.tableView reloadData];
        
        //update invite
        [self.apiController requestApproveFriendshipForFriend:friend];
    }
}

- (void)denyTouched:(UIButton*)sender
{
    DDInvitationTableViewCell *cell = (DDInvitationTableViewCell*)sender.superview;
    if ([cell isKindOfClass:[DDInvitationTableViewCell class]])
    {
        DDWingsViewControllerAlertView *alertView = [[[DDWingsViewControllerAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Are you sure you want to ignore this invitation?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Yes, Ignore", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil] autorelease];
        alertView.tag = kTagConfirmDeleteFriendshipAlert;
        alertView.shortUser = cell.shortUser;
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
        messageComposer.body = [NSString stringWithFormat:@"Become my wing on DoubleDate! %@%@", [DDTools serverUrlPath], [DDAuthenticationController currentUser].invitePath];
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
    if (indexPath.section == 0)
        return [DDInvitationTableViewCell height];
    return [DDWingTableViewCell height];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check if we need expand
    if (!self.isSelectingMode)
    {
        //show hud
        [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
        
        //get cell
        DDWingTableViewCell *wingsTableViewCell = (DDWingTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath];
        
        //request information about user
        [self.apiController getFriend:wingsTableViewCell.shortUser];
        
        //deselect row
        [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    //inform delegate about selecting
    [self.delegate wingsViewController:self didSelectUser:[(DDWingTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath] shortUser]];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (BOOL)tableView:(UITableView *)aTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 1);
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //get cell
        DDWingTableViewCell *wingsTableViewCell = (DDWingTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath];
        if ([wingsTableViewCell isKindOfClass:[DDWingTableViewCell class]])
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [[self pendingInvitations] count];
    else if (section == 1)
        return [[self wings] count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set identifier
    NSString *cellIdentifier = nil;
    if (indexPath.section == 1)
        cellIdentifier = NSStringFromClass([DDWingTableViewCell class]);
    else if (indexPath.section == 0)
        cellIdentifier = NSStringFromClass([DDInvitationTableViewCell class]);
    assert(cellIdentifier);
    
    //create cell if needed
    DDWingTableViewCell *tableViewCell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!tableViewCell)
    {
        tableViewCell = [[[UINib nibWithNibName:cellIdentifier bundle:nil] instantiateWithOwner:aTableView options:nil] objectAtIndex:0];
    }
    
    //unset friend
    DDShortUser *friend = nil;
    
    //check for wings
    if (indexPath.section == 1)
    {
        friend = [[self wings] objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 0)
    {
        friend = [[self pendingInvitations] objectAtIndex:indexPath.row];
    }
    
    //add handlers
    if ([tableViewCell isKindOfClass:[DDInvitationTableViewCell class]])
    {
        DDInvitationTableViewCell *invitationTableViewCell = (DDInvitationTableViewCell*)tableViewCell;
        [invitationTableViewCell.buttonAccept removeTarget:self action:@selector(inviteTouched:) forControlEvents:UIControlEventTouchUpInside];
        [invitationTableViewCell.buttonAccept addTarget:self action:@selector(inviteTouched:) forControlEvents:UIControlEventTouchUpInside];
        [invitationTableViewCell.buttonDeny removeTarget:self action:@selector(denyTouched:) forControlEvents:UIControlEventTouchUpInside];
        [invitationTableViewCell.buttonDeny addTarget:self action:@selector(denyTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //save data
    [tableViewCell setShortUser:friend];
    
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
    [self performSelector:@selector(onDataRefreshed) withObject:nil afterDelay:0];
}

- (void)getFriendsDidFailedWithError:(NSError*)error
{
    //save friends
    [friends_ release];
    friends_ = [[NSMutableArray alloc] init];
    
    //inform about reloaded data
    [self performSelector:@selector(onDataRefreshed) withObject:nil afterDelay:0];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)requestApproveFriendshipForFriendSucceed:(DDShortUser*)friend
{
}

- (void)requestApproveFriendshipForFriendDidFailedWithError:(NSError*)error
{
    //reload data
    [self startRefreshWithText:NSLocalizedString(@"Loading", nil)];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
    
    //update current user
    [DDAuthenticationController updateCurrentUser];
}

- (void)requestDenyFriendshipForFriendSucceed
{
}

- (void)requestDenyFriendshipForFriendDidFailedWithError:(NSError*)error
{
    //reload data
    [self startRefreshWithText:NSLocalizedString(@"Loading", nil)];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
    
    //update current user
    [DDAuthenticationController updateCurrentUser];
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
    meViewController.backButtonTitle = NSLocalizedString(@"Wings", nil);
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
            DDShortUser *friend = wingsAlertView.shortUser;
            
            //remove silent
            [friends_ removeObject:friend];
            
            //unset number of unread wings
            [DDAuthenticationController currentUser].pendingWingsCount = [NSNumber numberWithInt:[[self pendingInvitations] count]];
            
            //update application badge
            [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] updateApplicationBadge];
            
            //reload the table
            [self.tableView reloadData];
            
            //update no data view
            [self updateNoDataView];
            
            //send request
            [self.apiController requestDenyFriendshipForFriend:friend];
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
            
            //reload the table
            [self.tableView reloadData];
            
            //update no data view
            [self updateNoDataView];
            
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
    //request friends
    friendsRequest_ = [self.apiController getFriends];
}

#pragma mark -
#pragma mark -

- (void)objectUpdatedNotification:(NSNotification*)notification
{
    //save request method
    RKRequestMethod method = [[[notification userInfo] objectForKey:DDObjectsControllerDidUpdateObjectRestKitMethodUserInfoKey] intValue];
    
    //check object
    if ([[notification object] isKindOfClass:[DDShortUser class]])
    {
        //check method
        if (method == RKRequestMethodPOST)
        {
            //check if friend is already exist
            DDShortUser *friendToAdd = [notification object];
            BOOL exist = NO;
            for (DDShortUser *shortUser in friends_)
            {
                if ([[shortUser identifier] intValue] == [[friendToAdd identifier] intValue])
                    exist = YES;
            }
            
            //check if not exist
            if (!exist)
            {
                //add object
                [friends_ addObject:friendToAdd];
                
                //reload the table
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                
                //update no data view
                [self updateNoDataView];
            }
        }
    }
}


@end
