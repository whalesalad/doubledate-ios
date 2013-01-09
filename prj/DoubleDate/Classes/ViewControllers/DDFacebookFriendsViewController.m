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
#import "DDWingTableViewCell.h"
#import "DDMeViewController.h"
#import "DDTools.h"
#import "MBProgressHUD.h"
#import "DDBarButtonItem.h"
#import "DDTableViewController+Refresh.h"

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
    
    //add left button
    self.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Cancel", nil) target:self action:@selector(cancelTouched:)];
    
    //add right button
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Add", nil) target:self action:@selector(addTouched:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check if we need to make a request
    if (!friends_)
    {
        //show loading
        [self startRefreshWithText:NSLocalizedString(@"Loading", nil)];
        
        //search for placemarks
        [self.apiController getFacebookFriends];
    }
    
    //update navigation bar
    [self updateNavifationBar];
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
        if ([friend.name rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)
            [friends addObject:friend];
    }
    
    return friends;
}

- (NSArray*)sectionsForTableView:(UITableView*)aTableView
{
    //init result
    NSMutableArray *ret = [NSMutableArray array];
    
    //check each friend
    for (DDShortUser *friend in [self friendsForTableView:aTableView])
    {
        //get first symbol
        NSString *firstSymbol = [[[friend name] substringWithRange:NSMakeRange(0, 1)] capitalizedString];

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
        //add if name started from needed symbol
        if ([[[[friend name] substringWithRange:NSMakeRange(0, 1)] capitalizedString] isEqualToString:firstSymbol])
            [ret addObject:friend];
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
    if ([friendsToInvite_ count])
    {
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Invite %d Friend", nil), [friendsToInvite_ count]];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"Facebook Friends", nil);
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
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
            if ([[lowest name] compare:[u name] options:NSCaseInsensitiveSearch] == NSOrderedDescending)
                lowest = u;
        }
        [ret addObject:lowest];
        [friendsToRemove removeObject:lowest];
    }
    
    return ret;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DDWingTableViewCell height];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //add user to invite
    DDWingTableViewCell *tableViewCell = (DDWingTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath];
    
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

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView
{
    return [self sectionsForTableView:aTableView];
}

- (NSInteger)tableView:(UITableView *)aTableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[self sectionsForTableView:aTableView] indexOfObject:title];
}

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
    NSString *cellIdentifier = NSStringFromClass([DDWingTableViewCell class]);
    
    //create cell if needed
    DDWingTableViewCell *tableViewCell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!tableViewCell)
    {
        tableViewCell = [[[UINib nibWithNibName:cellIdentifier bundle:nil] instantiateWithOwner:aTableView options:nil] objectAtIndex:0];
    }
    
    //save friend
    DDShortUser *friend = [[self friendsForTableView:aTableView forSection:indexPath.section] objectAtIndex:indexPath.row];
    
    //save data
    [tableViewCell setShortUser:friend];
    
    //update layouts
    [tableViewCell setNeedsLayout];
    
    //check if user is already invited
    BOOL invited = [friendsToInvite_ containsObject:tableViewCell.shortUser];
    
    //apply checkmark style
    if (invited)
        tableViewCell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        tableViewCell.accessoryType = UITableViewCellAccessoryNone;
    
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
