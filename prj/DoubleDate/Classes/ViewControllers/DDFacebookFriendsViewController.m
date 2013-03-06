//
//  DDFacebookFriendsViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDFacebookFriendsViewController.h"
#import "DDAPIController.h"
#import "DDShortUser.h"
#import "DDMeViewController.h"
#import "DDTools.h"
#import "MBProgressHUD.h"
#import "DDBarButtonItem.h"
#import "DDTableViewController+Refresh.h"
#import "DDShortUserTableViewCell.h"
#import "DDWingTableViewCell.h"
#import "UIImageView+WebCache.h"

#define kFriendsOnDoubleDateTitle NSLocalizedString(@"Friends on DoubleDate", nil)

#define kTagInviteErrorAlert 5234

@interface DDFacebookFriendsViewControllerTableViewCell : UITableViewCell

@property(nonatomic, retain) DDShortUser *friend;

@end

@implementation DDFacebookFriendsViewControllerTableViewCell

@synthesize friend;

- (void)dealloc
{
    [friend release];
    [super dealloc];
}

@end

@interface DDFacebookFriendsViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

- (void)updateNavifationBar;
- (NSString*)nameOfUser:(DDShortUser*)shortUser;

@end

@implementation DDFacebookFriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        friendsToInvite_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //update navigation bar
    [self updateNavifationBar];
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
    [friendsToInvite_ release];
    [friends_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (NSArray*)friendsForTableView:(UITableView*)aTableView
{
    //check for disabled search
    if ([self.searchTerm length] == 0)
        return friends_;
    
    //result
    NSMutableArray *friends = [NSMutableArray array];
    
    //save search term
    NSString *searchTerm = self.searchTerm;
    
    //check each item
    for (DDShortUser *friend in friends_)
    {
        if ([[self nameOfUser:friend] rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)
            [friends addObject:friend];
    }
    
    return friends;
}

- (NSArray*)sectionsForTableView:(UITableView*)aTableView
{
    //init result
    NSMutableArray *ret = [NSMutableArray array];
    
    //add friends on doubledate title
    for (DDShortUser *friend in [self friendsForTableView:aTableView])
    {
        if (friend.identifier)
        {
            [ret addObject:kFriendsOnDoubleDateTitle];
            break;
        }
    }
    
    //check each friend
    for (DDShortUser *friend in [self friendsForTableView:aTableView])
    {
        //check friend on doubledate
        if (friend.identifier)
            continue;
        
        //get first symbol
        NSString *firstSymbol = [[[self nameOfUser:friend] substringWithRange:NSMakeRange(0, 1)] capitalizedString];

        //add if not exist
        if (![ret containsObject:firstSymbol])
            [ret addObject:firstSymbol];
    }
    
    return ret;
}

- (NSArray*)friendsForTableView:(UITableView*)aTableView forSection:(NSInteger)section
{
    //init result
    NSMutableArray *ret = [NSMutableArray array];
    
    //get section title
    NSString *firstSymbol = [[self sectionsForTableView:aTableView] objectAtIndex:section];
    
    //check each friend
    for (DDShortUser *friend in [self friendsForTableView:aTableView])
    {
        //check friend on dd
        if (friend.identifier)
        {
            if ([firstSymbol isEqualToString:kFriendsOnDoubleDateTitle])
                [ret addObject:friend];
        }
        else
        {
            //add if name started from needed symbol
            if ([[[[self nameOfUser:friend] substringWithRange:NSMakeRange(0, 1)] capitalizedString] isEqualToString:firstSymbol])
                [ret addObject:friend];
        }
    }
    
    return ret;
}

- (void)addTouched:(id)sender
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Updating", nil) animated:NO];
    
    //init arrays
    NSMutableArray *fbIds = [NSMutableArray array];
    NSMutableArray *ddIds = [NSMutableArray array];
    
    //fill data
    for (DDShortUser *friend in friendsToInvite_)
    {
        if (friend.facebookId)
            [fbIds addObject:friend.facebookId];
        else if (friend.identifier)
            [ddIds addObject:[friend.identifier stringValue]];
    }
    
    //make api call
    [self.apiController requestInvitationsForFBUsers:fbIds andDDUsers:ddIds];
}

- (void)cancelTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateNavifationBar
{
    //set title
    self.navigationItem.title = NSLocalizedString(@"Friends", nil);
    
    //add left button
    self.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Cancel", nil) target:self action:@selector(cancelTouched:)];
            
    //set title
    if ([friendsToInvite_ count])
    {
        //add right button
        self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Invite %d User%@", nil), [friendsToInvite_ count], [friendsToInvite_ count]>1?@"s":@""] target:self action:@selector(addTouched:)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Invite", nil)] target:self action:@selector(addTouched:)];
    }
    
    //apply right button style
    self.navigationItem.rightBarButtonItem.enabled = [friendsToInvite_ count] > 0;
}

- (NSString*)nameOfUser:(DDShortUser*)shortUser
{
    if ([shortUser name])
        return [shortUser name];
    return [shortUser fullName];
}

- (NSArray*)sortedFriends:(NSArray*)friends
{
    NSMutableArray *friendsToRemove = [NSMutableArray arrayWithArray:friends];
    NSMutableArray *ret = [NSMutableArray array];
    
    while ([friendsToRemove count])
    {
        DDShortUser *lowest = [friendsToRemove objectAtIndex:0];
        for (DDShortUser *u in friendsToRemove)
        {
            if ([[self nameOfUser:lowest] compare:[self nameOfUser:u] options:NSCaseInsensitiveSearch] == NSOrderedDescending)
                lowest = u;
        }
        [ret addObject:lowest];
        [friendsToRemove removeObject:lowest];
    }
    
    return ret;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    return [[self tableView:aTableView viewForHeaderInSection:section] frame].size.height;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    if ([self tableView:aTableView numberOfRowsInSection:section] == 0)
        return nil;
    
    return [self viewForHeaderWithMainText:[self tableView:aTableView titleForHeaderInSection:section] detailedText:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DDShortUserTableViewCell height];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //add user to invite
    DDShortUserTableViewCell *tableViewCell = (DDShortUserTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath];
    
    //update state
    if ([friendsToInvite_ containsObject:tableViewCell.shortUser])
        [friendsToInvite_ removeObject:tableViewCell.shortUser];
    else
        [friendsToInvite_ addObject:tableViewCell.shortUser];
    
    //update navigation bar
    [self updateNavifationBar];
    
    //update cell
    [aTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -
#pragma mark UITableViewDataSource

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView
//{
//    return [self sectionsForTableView:aTableView];
//}
//
//- (NSInteger)tableView:(UITableView *)aTableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    return [[self sectionsForTableView:aTableView] indexOfObject:title];
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return [[self sectionsForTableView:aTableView] count];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    return [[self sectionsForTableView:aTableView] objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [[self friendsForTableView:aTableView forSection:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set identifier
    NSString *cellIdentifier = NSStringFromClass([DDShortUserTableViewCell class]);
    
    //create cell if needed
    DDShortUserTableViewCell *tableViewCell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!tableViewCell)
    {
        tableViewCell = [[[UINib nibWithNibName:cellIdentifier bundle:nil] instantiateWithOwner:aTableView options:nil] objectAtIndex:0];
    }
    
    //save friend
    DDShortUser *friend = [[self friendsForTableView:aTableView forSection:indexPath.section] objectAtIndex:indexPath.row];
    
    //save data
    [tableViewCell setShortUser:friend];
    
    //check if user is already invited
    BOOL invited = [friendsToInvite_ containsObject:tableViewCell.shortUser];
    
    //apply checkmark style
    tableViewCell.imageViewCheckmark.hidden = !invited;
    
    return tableViewCell;
}

#pragma mark -
#pragma mark API

- (void)getFacebookFriendsSucceed:(NSArray*)friends
{
    //save facebook friends
    [friends_ release];
    friends_ = [[NSMutableArray alloc] initWithArray:[self sortedFriends:friends]];
    
    //finish refresh
    [self finishRefresh];
    
    //reload data
    [self.tableView reloadData];
}

- (void)getFacebookFriendsDidFailedWithError:(NSError*)error
{
    //finish refresh
    [self finishRefresh];
    
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

- (void)requestInvitationsSucceed:(NSArray*)friends
{
    //hide hud
    [self hideHud:YES];
    
    //show succeed message
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Great! We've invited %d of your friends.", nil), [friendsToInvite_ count]];

    //show completed hud
    [self showCompletedHudWithText:message];
    
    //go back
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)requestInvitationsDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Try Again", nil), nil] autorelease];
    alert.tag = kTagInviteErrorAlert;
    [alert show];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //check for invitation error
    if (alertView.tag == kTagInviteErrorAlert)
    {
        //check needed action
        if (buttonIndex == 0)
            [self.navigationController popViewControllerAnimated:YES];
        else
            [self addTouched:nil];
    }
}

#pragma mark -
#pragma mark Refresh

- (void)onRefresh
{
    //request friends
    [self.apiController getFacebookFriends];
}

@end
