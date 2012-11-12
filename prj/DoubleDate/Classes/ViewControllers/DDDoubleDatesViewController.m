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

typedef enum
{
    DDDoubleDatesViewControllerFilterNone,
    DDDoubleDatesViewControllerFilterCreated,
    DDDoubleDatesViewControllerFilterWing,
    DDDoubleDatesViewControllerFilterAttending,
} DDDoubleDatesViewControllerFilter;

@interface DDDoubleDatesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property(nonatomic, readonly) UISearchBar *searchBar;

- (void)refresh:(BOOL)animated;
- (NSArray*)doubleDatesForSection:(NSInteger)section;
- (void)segmentedControlTouched:(id)sender;
- (void)onDataRefreshed;
- (void)removeDoubleDate:(DDDoubleDate*)doubleDate;

@end

@implementation DDDoubleDatesViewController

@synthesize tableView;
@synthesize user;
@synthesize doubleDateToAdd;

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
    UISegmentedControl *segmentedControl = [[[DDSegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"List", nil), NSLocalizedString(@"Mine", nil), nil]] autorelease];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    if (mode_ == DDDoubleDatesViewControllerModeAll)
        segmentedControl.selectedSegmentIndex = 0;
    else if (mode_ == DDDoubleDatesViewControllerModeMine)
        segmentedControl.selectedSegmentIndex = 1;
    [segmentedControl addTarget:self action:@selector(segmentedControlTouched:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentedControl;
    
    //add left button
    self.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"+", nil) target:self action:@selector(plusTouched:)];
    
    //add right button
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Edit", nil) target:self action:@selector(editTouched:)];
    
    //set header as search bar
    DDSearchBar *searchBar = [[[DDSearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    searchBar.delegate = self;
    searchBar.placeholder = NSLocalizedString(@"All doubledates", nil);
    self.tableView.tableHeaderView = searchBar;
        
    //move header
    self.tableView.contentOffset = CGPointMake(0, searchBar.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //add doubledate if needed
    if (self.doubleDateToAdd)
    {
        //add doubledate
        [allDoubleDates_ addObject:self.doubleDateToAdd];
        [mineDoubleDates_ addObject:self.doubleDateToAdd];
        
        //reload the table
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check if we need to make a request
    if (!allDoubleDates_ || !mineDoubleDates_)
        [self refresh:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [tableView release], tableView = nil;
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
    [tableView release];
    [user release];
    [doubleDateToAdd release];
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
    
    //set right button
    if (self.tableView.editing)
        self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Done", nil) target:self action:@selector(editTouched:)];
    else
        self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Edit", nil) target:self action:@selector(editTouched:)];
}

- (void)refresh:(BOOL)animated
{
    //unset old values
    [allDoubleDates_ release];
    allDoubleDates_ = nil;
    [mineDoubleDates_ release];
    mineDoubleDates_ = nil;
    
    //show hud
    [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:animated];
    
    //request doubledates
    [self.apiController getDoubleDates];
    
    //request doubledates
    [self.apiController getMyDoubleDates];
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
    return YES;
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
    cell.doubleDate = [[self doubleDatesForSection:indexPath.section] objectAtIndex:indexPath.row];
    
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
    //reload data
    [self refresh:YES];
    
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

@end
