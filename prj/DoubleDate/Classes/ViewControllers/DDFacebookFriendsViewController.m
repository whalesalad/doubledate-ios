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
#import "DDUserTableViewCell.h"
#import "DDMeViewController.h"
#import "DDTools.h"

@interface DDFacebookFriendsViewControllerButton : UIButton

@property(nonatomic, retain) DDShortUser *friend;

@end

@implementation DDFacebookFriendsViewControllerButton

@synthesize friend;

- (void)dealloc
{
    [friend release];
    [super dealloc];
}

@end

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

@synthesize tableView;

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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //add right button
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(addTouched:)] autorelease];
    
    //check if we need to make a request
    if (!friendsRequired_)
    {
        //save that interests already requested
        friendsRequired_ = YES;
        
        //show hud
        [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
        
        //search for placemarks
        [self.apiController getFacebookFriends];
    }
    
    //update navigation bar
    [self updateNavifationBar];
}

- (void)viewDidUnload
{
    [tableView release], tableView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [friendsToInvite_ release];
    [tableView release];
    [friends_ release];
    [super dealloc];
}

#pragma mark -
#pragma comment other

- (NSArray*)friendsForTableView:(UITableView*)aTableView
{
    //check all data
    if (aTableView == self.tableView)
        return [NSArray arrayWithArray:friends_];
    else if (aTableView == self.searchDisplayController.searchResultsTableView)
    {
        //result
        NSMutableArray *friends = [NSMutableArray array];
        
        //save search term
        NSString *searchTerm = self.searchDisplayController.searchBar.text;
        
        //check each item
        for (DDShortUser *friend in friends_)
        {
            if ([friend.name rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)
                [friends addObject:friend];
        }
        
        return friends;
    }
    
    return nil;
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

- (void)removeTouched:(DDFacebookFriendsViewControllerButton*)sender
{
    //remove from list
    [friendsToInvite_ removeObject:sender.friend];
    
    //update navigation bar
    [self updateNavifationBar];
    
    //reload the table
    [self.tableView reloadData];
}

- (void)inviteTouched:(DDFacebookFriendsViewControllerButton*)sender
{
    //add to list
    [friendsToInvite_ addObject:sender.friend];
    
    //update navigation bar
    [self updateNavifationBar];
    
    //reload the table
    [self.tableView reloadData];
}

#pragma mark -
#pragma comment UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DDUserTableViewCell height];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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

#pragma mark -
#pragma comment UITableViewDataSource

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
    NSString *cellIdentifier = [[DDUserTableViewCell class] description];
    
    //create cell if needed
    DDUserTableViewCell *tableViewCell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!tableViewCell)
        tableViewCell = [[[DDUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    
    //set selection style
    tableViewCell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    //set type
    tableViewCell.type = DDUserTableViewCellTypeFacebook;
    
    //save friend
    DDShortUser *friend = [[self friendsForTableView:aTableView forSection:indexPath.section] objectAtIndex:indexPath.row];
    
    //save data
    [tableViewCell setShortUser:friend];
    
    //update layouts
    [tableViewCell setNeedsLayout];
    
    //customize accessory view
    {
        //check if user is already invited
        BOOL invited = [friendsToInvite_ containsObject:tableViewCell.shortUser];
        
        //set accessory button
        DDFacebookFriendsViewControllerButton *button = [DDFacebookFriendsViewControllerButton buttonWithType:UIButtonTypeCustom];
        button.friend = friend;
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        UIImage *image = nil;
        NSString *title = nil;
        SEL sel = nil;
        if (!invited)
        {
            image = [UIImage imageNamed:@"button-blue.png"];
            title = NSLocalizedString(@"Invite", nil);
            sel = @selector(inviteTouched:);
        }
        else
        {
            image = [UIImage imageNamed:@"button-grey.png"];
            title = NSLocalizedString(@"Remove", nil);
            sel = @selector(removeTouched:);
        }
        CGFloat width = [title sizeWithFont:button.titleLabel.font].width + 10;
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, image.size.width/2, 0, image.size.width/2)];
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
        imageView.frame = CGRectMake(0, 0, width, image.size.height);
        image = [DDTools imageFromView:imageView];
        button.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [button setTitle:title forState:UIControlStateNormal];
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
        tableViewCell.accessoryView = button;
    }
    
    
    return tableViewCell;
}

#pragma mark -
#pragma comment API

- (void)getFacebookFriendsSucceed:(NSArray*)friends
{
    //save facebook friends
    [friends_ release];
    friends_ = [[NSMutableArray alloc] initWithArray:friends];
    
    //hide hud
    [self hideHud:YES];
    
    //reload data
    [self.tableView reloadData];
}

- (void)getFacebookFriendsDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
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
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:@"OK" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)requestInvitationsDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
