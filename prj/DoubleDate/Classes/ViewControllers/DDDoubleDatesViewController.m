//
//  DDDoubleDatesViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDatesViewController.h"
#import "DDCreateDoubleDateViewController.h"
#import "DDDoubleDate.h"
#import "DDDoubleDateTableViewCell.h"
#import "DDBarButtonItem.h"
#import "DDSegmentedControl.h"
#import "DDSearchBar.h"
#import "DDPlacemark.h"
#import "DDShortUser.h"
#import "DDUser.h"
#import "DDDoubleDateFilter.h"
#import "DDTableViewController+Refresh.h"

typedef enum
{
    DDDoubleDatesViewControllerFilterNone,
    DDDoubleDatesViewControllerFilterCreated,
    DDDoubleDatesViewControllerFilterWing,
    DDDoubleDatesViewControllerFilterAttending,
} DDDoubleDatesViewControllerFilter;

@interface DDDoubleDatesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property(nonatomic, readonly) UISearchBar *searchBar;

- (NSArray*)doubleDatesForSection:(NSInteger)section;
- (void)segmentedControlTouched:(id)sender;
- (void)onDataRefreshed;
- (void)removeDoubleDate:(DDDoubleDate*)doubleDate;
- (void)updateNavigationBar;
- (void)updateSearchBar;

@end

@implementation DDDoubleDatesViewController

@synthesize user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        mode_ = DDDoubleDatesViewControllerModeAll;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    UISegmentedControl *segmentedControl = [[[DDSegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"LIST", nil), NSLocalizedString(@"MINE", nil), nil]] autorelease];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    if (mode_ == DDDoubleDatesViewControllerModeAll)
        segmentedControl.selectedSegmentIndex = 0;
    else if (mode_ == DDDoubleDatesViewControllerModeMine)
        segmentedControl.selectedSegmentIndex = 1;
    [segmentedControl addTarget:self action:@selector(segmentedControlTouched:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentedControl;
    
    //add left button
    self.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"+", nil) target:self action:@selector(plusTouched:)];
    
    //customize separators
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //update navigation bar
    [self updateNavigationBar];
    
    //update search bar
    [self updateSearchBar];
    
    //move header
    self.tableView.contentOffset = CGPointMake(0, self.searchBar.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check if we need to make a request
    if (!allDoubleDates_ || !mineDoubleDates_)
        [self startRefreshWithText:NSLocalizedString(@"Loading", nil)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [allDoubleDates_ release];
    [mineDoubleDates_ release];
    [searchTerm_ release];
    [user release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (void)plusTouched:(id)sender
{
    DDCreateDoubleDateViewController *viewController = [[[DDCreateDoubleDateViewController alloc] init] autorelease];
    viewController.user = self.user;
    viewController.doubleDatesViewController = self;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)editTouched:(id)sender
{
    //update edigin style
    self.tableView.editing = !self.tableView.editing;
    
    //update navigation bar
    [self updateNavigationBar];
}

- (NSArray*)filteredDoubleDates:(NSArray*)doubleDates filter:(DDDoubleDatesViewControllerFilter)filter
{
    NSMutableArray *ret = [NSMutableArray array];
    for (DDDoubleDate *dd in doubleDates)
    {
        //check search condition
        BOOL existInSearch = [searchTerm_ length] == 0;
        if (searchTerm_)
        {
            if (dd.title && [dd.title rangeOfString:searchTerm_ options:NSCaseInsensitiveSearch].location != NSNotFound)
                existInSearch = YES;
            if (dd.details && [dd.details rangeOfString:searchTerm_ options:NSCaseInsensitiveSearch].location != NSNotFound)
                existInSearch = YES;
            if (dd.location.name && [dd.location.name rangeOfString:searchTerm_ options:NSCaseInsensitiveSearch].location != NSNotFound)
                existInSearch = YES;
        }
        
        //check filter condition
        BOOL existInFilter = filter == DDDoubleDatesViewControllerFilterNone;
        switch (filter) {
            case DDDoubleDatesViewControllerFilterCreated:
                existInFilter = [self.user.userId intValue] == [dd.user.identifier intValue];
                break;
            case DDDoubleDatesViewControllerFilterWing:
                existInFilter = [self.user.userId intValue] == [dd.wing.identifier intValue];
                break;
                
            default:
                break;
        }
        
        //check if we can add the double date
        if (existInSearch && existInFilter)
            [ret addObject:dd];
    }
    return ret;
}

- (NSArray*)doubleDatesForSection:(NSInteger)section
{
    if (mode_ == DDDoubleDatesViewControllerModeAll)
        return [self filteredDoubleDates:allDoubleDates_ filter:DDDoubleDatesViewControllerFilterNone];
    else if (mode_ == DDDoubleDatesViewControllerModeMine)
    {
        switch (section) {
            case 0:
                return [self filteredDoubleDates:mineDoubleDates_ filter:DDDoubleDatesViewControllerFilterCreated];
                break;
            case 1:
                return [self filteredDoubleDates:mineDoubleDates_ filter:DDDoubleDatesViewControllerFilterWing];
                break;
            case 2:
                return [self filteredDoubleDates:mineDoubleDates_ filter:DDDoubleDatesViewControllerFilterAttending];
                break;
            default:
                break;
        }
    }
    return nil;
}

- (void)segmentedControlTouched:(UISegmentedControl*)sender
{
    //switch mode
    switch (sender.selectedSegmentIndex)
    {
        case 0:
            mode_ = DDDoubleDatesViewControllerModeAll;
            break;
        case 1:
            mode_ = DDDoubleDatesViewControllerModeMine;
            break;
        default:
            break;
    }
    
    //update navigation bar
    [self updateNavigationBar];
    
    //update search bar
    [self updateSearchBar];
    
    //reload the table
    [self.tableView reloadData];
}

- (void)onDataRefreshed
{
    //check for both data
    if (allDoubleDates_ && mineDoubleDates_)
    {
        //hide hud
        [self hideHud:YES];
        
        //make super
        [self finishRefresh];
    
        //reload data
        [self.tableView reloadData];
    }
}

- (void)removeDoubleDate:(DDDoubleDate*)doubleDate
{
    //init array
    NSMutableArray *doubleDatesToRemove = [NSMutableArray array];

    //add from all doubledates
    for (DDDoubleDate *d in allDoubleDates_)
    {
        if ([[d identifier] intValue] == [[doubleDate identifier] intValue])
            [doubleDatesToRemove addObject:d];
    }
    
    //add from mine doubledates
    for (DDDoubleDate *d in mineDoubleDates_)
    {
        if ([[d identifier] intValue] == [[doubleDate identifier] intValue])
            [doubleDatesToRemove addObject:d];
    }
    
    //remove
    while ([doubleDatesToRemove count])
    {
        DDDoubleDate *d = [doubleDatesToRemove lastObject];
        [allDoubleDates_ removeObject:d];
        [mineDoubleDates_ removeObject:d];
        [doubleDatesToRemove removeObject:d];
    }
}

- (void)updateNavigationBar
{
    //check current mode
    if (mode_ == DDDoubleDatesViewControllerModeMine)
    {
        if (self.tableView.editing)
            self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"DONE", nil) target:self action:@selector(editTouched:)];
        else
            self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"EDIT", nil) target:self action:@selector(editTouched:)];
    }
    else
        self.navigationItem.rightBarButtonItem = nil;
}

- (void)updateSearchBar
{
    //check current mode
    if (mode_ == DDDoubleDatesViewControllerModeAll)
    {
        //set header as search bar
        DDSearchBar *searchBar = [[[DDSearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
        searchBar.delegate = self;
        searchBar.placeholder = NSLocalizedString(@"Search DoubleDates…", nil);
        searchBar.text = searchTerm_;
        self.tableView.tableHeaderView = searchBar;
    }
    else
    {
        UIView *v = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, FLT_MIN)] autorelease];
        v.backgroundColor = [UIColor clearColor];
        self.tableView.tableHeaderView = v;
    }
}

- (UISearchBar*)searchBar
{
    return (UISearchBar*)self.tableView.tableHeaderView;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [self tableView:aTableView viewForHeaderInSection:section];
    if (headerView)
        return headerView.frame.size.height;
    return FLT_MIN;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForFooterInSection:(NSInteger)section
{
    return FLT_MIN;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    if ([self tableView:aTableView numberOfRowsInSection:section] > 0)
    {
        if (mode_ == DDDoubleDatesViewControllerModeMine)
        {
            switch (section) {
                case 0:
                    return [self viewForHeaderWithMainText:NSLocalizedString(@"I'VE CREATED", nil) detailedText:nil];
                    break;
                case 1:
                    return [self viewForHeaderWithMainText:NSLocalizedString(@"I'M A WING", nil) detailedText:nil];
                    break;
                case 2:
                    return [self viewForHeaderWithMainText:NSLocalizedString(@"I'M ATTENDING", nil) detailedText:nil];
                    break;
                default:
                    break;
            }
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DDDoubleDateTableViewCell height];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (BOOL)tableView:(UITableView *)aTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (mode_ == DDDoubleDatesViewControllerModeMine) && (indexPath.section == 0);
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //get doubledate
        DDDoubleDate *doubleDate = [[[self doubleDatesForSection:indexPath.section] objectAtIndex:indexPath.row] retain];

        //remove sliently
        [self removeDoubleDate:doubleDate];
        
        //reload the table
        [self.tableView reloadData];
        
        //request delete doubledate
        [self.apiController requestDeleteDoubleDate:doubleDate];
        
        //release object
        [doubleDate release];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (mode_ == DDDoubleDatesViewControllerModeMine)
        return 3;
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [[self doubleDatesForSection:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //save class
    Class cellClass = [DDDoubleDateTableViewCell class];
    
    //create cell
    DDDoubleDateTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:[cellClass description]];
    if (!cell)
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[cellClass description]];
    
    //set accessory view
    cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dd-tablecell-detail-arrow.png"]] autorelease];
    
    //apply data
    if (indexPath.row < [[self doubleDatesForSection:indexPath.section] count])
        cell.doubleDate = [[self doubleDatesForSection:indexPath.section] objectAtIndex:indexPath.row];
    else
        cell.doubleDate = nil;
    
    return cell;
}

#pragma mark -
#pragma mark API

- (void)getDoubleDatesSucceed:(NSArray*)doubleDates
{
    //save doubledates
    [allDoubleDates_ release];
    allDoubleDates_ = [[NSMutableArray arrayWithArray:doubleDates] retain];
    
    //inform about completion
    [self onDataRefreshed];
}

- (void)getDoubleDatesDidFailedWithError:(NSError*)error
{
    //save friends
    [allDoubleDates_ release];
    allDoubleDates_ = [[NSMutableArray alloc] init];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
    
    //inform about completion
    [self onDataRefreshed];
}

- (void)getMyDoubleDatesSucceed:(NSArray*)doubleDates
{
    //save doubledates
    [mineDoubleDates_ release];
    mineDoubleDates_ = [[NSMutableArray arrayWithArray:doubleDates] retain];
    
    //inform about completion
    [self onDataRefreshed];
}

- (void)getMyDoubleDatesDidFailedWithError:(NSError*)error
{
    //save friends
    [mineDoubleDates_ release];
    mineDoubleDates_ = [[NSMutableArray alloc] init];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
    
    //inform about completion
    [self onDataRefreshed];
}

- (void)requestDeleteDoubleDateSucceed
{
}

- (void)requestDeleteDoubleDateDidFailedWithError:(NSError*)error
{
    //refresh
    [self startRefreshWithText:NSLocalizedString(@"Loading", nil)];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchTerm_ release];
    searchTerm_ = [[searchBar text] retain];
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

#pragma mark -
#pragma mark Refreshing

- (void)onRefresh
{
    //unset old values
    [allDoubleDates_ release];
    allDoubleDates_ = nil;
    [mineDoubleDates_ release];
    mineDoubleDates_ = nil;
    
    //request doubledates
    [self.apiController getDoubleDatesWithFilter:nil];
    
    //request doubledates
    [self.apiController getMyDoubleDates];
}

@end
