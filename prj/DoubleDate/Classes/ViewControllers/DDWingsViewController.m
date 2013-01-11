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
#import "DDWingTableViewCell.h"
#import "DDBarButtonItem.h"
#import "DDSegmentedControl.h"
#import "DDTableViewController+Refresh.h"
#import "DDWingTableViewCell.h"
#import "DDInvitationTableViewCell.h"

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

@interface DDWingsViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>

- (void)onDataRefreshed;
- (void)inviteBySms;
- (void)inviteByFacebook;
- (NSArray*)pendingInvitations;
- (NSArray*)wings;

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
    
    //add left button
    self.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"dd-button-add-icon.png"] target:self action:@selector(plusTouched:)];
    
    //add right button
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Edit", nil) target:self action:@selector(editTouched:)];
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

- (BOOL)isFriendshipExistInSearch:(DDFriendship*)friendship
{
    if ([[friendship.user identifier] intValue] != [[self.user userId] intValue])
        return [self isUserExistInSearch:friendship.user];
    if ([[friendship.friendUser identifier] intValue] != [[self.user userId] intValue])
        return [self isUserExistInSearch:friendship.friendUser];
    return NO;
}

- (NSArray*)pendingInvitations
{
    NSMutableArray *ret = [NSMutableArray array];
    for (DDFriendship *friendship in pendingInvitations_)
    {
        if ([self isFriendshipExistInSearch:friendship])
            [ret addObject:friendship];
    }
    return ret;
}

- (NSArray*)wings
{
    NSMutableArray *ret = [NSMutableArray array];
    for (DDShortUser *shortUser in friends_)
    {
        if ([self isUserExistInSearch:shortUser])
            [ret addObject:shortUser];
    }
    return ret;
}

- (void)onDataRefreshed
{
    //check both data received
    if (friends_ && pendingInvitations_)
    {
        //hide loading
        [self finishRefresh];
        
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
    
    //update title
    self.navigationItem.title = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
}

- (void)inviteTouched:(UIButton*)sender
{
    DDInvitationTableViewCell *cell = (DDInvitationTableViewCell*)sender.superview;
    if ([cell isKindOfClass:[DDInvitationTableViewCell class]])
    {
        //save friendship
        DDFriendship *friendship = (DDFriendship*)[cell.userData retain];
        
        //move friend from friendship
        [friends_ addObject:friendship.user];
        [pendingInvitations_ removeObject:friendship];
        
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
    DDInvitationTableViewCell *cell = (DDInvitationTableViewCell*)sender.superview;
    if ([cell isKindOfClass:[DDInvitationTableViewCell class]])
    {
        DDWingsViewControllerAlertView *alertView = [[[DDWingsViewControllerAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Are you sure you want to ignore this invitation?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Yes, Ignore", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil] autorelease];
        alertView.tag = kTagConfirmDeleteFriendshipAlert;
        alertView.shortUser = cell.shortUser;
        alertView.friendship = (DDFriendship*)cell.userData;
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
    DDFriendship *friendship = nil;
    
    //check for wings
    if (indexPath.section == 1)
    {
        friend = [[self wings] objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 0)
    {
        friendship = [[self pendingInvitations] objectAtIndex:indexPath.row];
        friend = friendship.user;
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
    [tableViewCell setUserData:friendship];
    
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
            DDFriendship *fiendship = [wingsAlertView.friendship retain];
            
            //remove silent
            [pendingInvitations_ removeObject:fiendship];
            
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
