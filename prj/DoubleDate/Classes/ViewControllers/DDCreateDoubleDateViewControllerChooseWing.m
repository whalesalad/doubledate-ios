//
//  DDCreateDoubleDateViewControllerChooseWing.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/24/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDCreateDoubleDateViewControllerChooseWing.h"
#import "DDAPIController.h"
#import "DDShortUser.h"
#import "DDSearchBar.h"
#import "DDTableViewCell.h"
#import "DDImageView.h"

#import <QuartzCore/QuartzCore.h>

@interface DDCreateDoubleDateViewControllerChooseWing ()<DDAPIControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property(nonatomic, readonly) UISearchBar *searchBar;
@property(nonatomic, readonly) UITableView *tableView;

@end

@implementation DDCreateDoubleDateViewControllerChooseWing

@synthesize delegate;
@synthesize wing;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    //make for supper
    [super viewDidAppear:animated];
    
    //check if we need to make a request
    if (!wings_)
    {
        //show hud
        [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
        
        //search for wings
        [self.apiController getFriends];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Wing", nil);
    
    //add table view
    tableView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    tableView_.dataSource = self;
    tableView_.delegate = self;
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView_];
    tableView_.backgroundColor = [UIColor clearColor];
    tableView_.backgroundView = nil;
    
    //set header as search bar
    DDSearchBar *searchBar = [[[DDSearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    searchBar.delegate = self;
    searchBar.placeholder = NSLocalizedString(@"All wings", nil);
    tableView_.tableHeaderView = searchBar;
    
    //move header
    tableView_.contentOffset = CGPointMake(0, searchBar.frame.size.height);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [tableView_ release], tableView_ = nil;
}

- (NSArray*)filteredWings
{
    NSMutableArray *ret = [NSMutableArray array];
    for (DDShortUser *user in wings_)
    {
        BOOL existInSearch = [self.searchBar.text length] == 0;
        if (self.searchBar.text)
        {
            if (user.name && [user.name rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch].location != NSNotFound)
                existInSearch = YES;
            if (user.fullName && [user.fullName rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch].location != NSNotFound)
                existInSearch = YES;
        }
        if (existInSearch)
            [ret addObject:user];
    }
    return ret;
}

- (UISearchBar*)searchBar
{
    return (UISearchBar*)tableView_.tableHeaderView;
}

- (UITableView*)tableView
{
    return tableView_;
}

- (BOOL)isUserSelected:(DDShortUser *)user
{
    return [[user identifier] intValue] == [[self.wing identifier] intValue];
}

- (void)dealloc
{
    [tableView_ release];
    [wing release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //save location
    DDShortUser *selectedUser = (DDShortUser*)[(DDTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath] userData];
    
    //save wing
    if ([self isUserSelected:selectedUser])
        self.wing = nil;
    else
        self.wing = selectedUser;
    
    //reload the cell
    [aTableView reloadData];
    
    //inform delegate
    [self.delegate createDoubleDateViewControllerChooseWingUpdatedWing:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DDTableViewCell height];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    return [[self tableView:aTableView viewForHeaderInSection:section] frame].size.height;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [[self filteredWings] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //save user
    DDShortUser *user = [[self filteredWings] objectAtIndex:indexPath.row];
    
    //create cell of needed type
    NSString *identifier = [[[self class] description] stringByAppendingString:@"DDUserTableViewCell"];
    DDTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
        cell = [[[DDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    
    //apply needed cell design
    [cell applyGroupedBackgroundStyleForTableView:aTableView withIndexPath:indexPath];
    
    //apply text
    cell.textLabel.text = [user fullName];

    //check for photo
    if ([user.photo downloadUrl])
    {
        //apply wing photo
        DDImageView *imageView = [[[DDImageView alloc] initWithFrame:CGRectMake(0, 0, 38, 38)] autorelease];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.cornerRadius = 19;
        imageView.layer.masksToBounds = YES;
        [cell attachImageView:imageView];
        
        //add photo overlay
        UIImageView *overlay = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user-photo-overlay.png"]] autorelease];
        overlay.frame = CGRectMake(-1.5f, -1, 41, 41);
        overlay.backgroundColor = [UIColor clearColor];
        [imageView addSubview:overlay];
        
        //reload image
        [imageView reloadFromUrl:[NSURL URLWithString:[user.photo downloadUrl]]];
    }
    else
        [cell attachImageView:nil];
    
    //save user data
    cell.userData = user;
    
    //update selected ui
    if ([self isUserSelected:user])
        cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]] autorelease];
    else
        cell.accessoryView = nil;
    
    return cell;
}

#pragma mark -
#pragma mark DDAPIControllerDelegate

- (void)getFriendsSucceed:(NSArray *)friends
{
    //hide hud
    [self hideHud:YES];
    
    //save placemarks
    [wings_ release];
    wings_ = [friends retain];
    
    //reload the table
    [tableView_ reloadData];
}

- (void)getFriendsDidFailedWithError:(NSError *)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [tableView_ reloadData];
    [searchBar resignFirstResponder];
}

@end
