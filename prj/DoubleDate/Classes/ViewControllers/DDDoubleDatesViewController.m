//
//  DDDoubleDatesViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDatesViewController.h"
#import "DDCreateDoubleDateViewController.h"
#import "DDDoubleDateFilterViewController.h"
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
#import "DDDoubleDateViewController.h"
#import "DDObjectsController.h"

typedef enum
{
    DDDoubleDatesViewControllerFilterNone,
    DDDoubleDatesViewControllerFilterCreated,
    DDDoubleDatesViewControllerFilterWing,
    DDDoubleDatesViewControllerFilterAttending,
} DDDoubleDatesViewControllerFilter;

@interface DDDoubleDatesViewController () <UITableViewDataSource, UITableViewDelegate, DDDoubleDateFilterViewControllerDelegate>

- (NSArray*)doubleDatesForSection:(NSInteger)section;
- (void)onDataRefreshed;
- (void)removeDoubleDate:(DDDoubleDate*)doubleDate;
- (void)updateNavigationBar;
- (void)updateSearchBar;

@end

@implementation DDDoubleDatesViewController

@synthesize user;
@synthesize searchFilter;
@synthesize mode = mode_;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        mode_ = DDDoubleDatesViewControllerModeAll;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectUpdatedNotification:) name:DDObjectsControllerDidUpdateObjectNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set needed title
    if (mode_ == DDDoubleDatesViewControllerModeAll)
        self.navigationItem.title = NSLocalizedString(@"DoubleDates", nil);
    else if (mode_ == DDDoubleDatesViewControllerModeMine)
        self.navigationItem.title = NSLocalizedString(@"My DoubleDates", nil);
    
    //add left button
    if (mode_ == DDDoubleDatesViewControllerModeMine)
        self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"dd-button-add-icon.png"] target:self action:@selector(plusTouched:)];
    else
        self.navigationItem.rightBarButtonItem = nil;
    
    //customize separators
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //update navigation bar
    [self updateNavigationBar];
    
    //update search bar
    [self updateSearchBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check if we need to make a request
    if (!doubleDates_)
        [self startRefreshWithText:NSLocalizedString(@"Loading", nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [doubleDates_ release];
    [user release];
    [searchFilter release];
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

- (void)filterTouched:(id)sender
{
    DDDoubleDateFilterViewController *viewController = [[[DDDoubleDateFilterViewController alloc] initWithFilter:self.searchFilter] autorelease];
    viewController.delegate = self;
    [self.navigationController presentViewController:[[[UINavigationController alloc] initWithRootViewController:viewController] autorelease] animated:YES completion:^{
    }];
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
        BOOL existInSearch = [self.searchTerm length] == 0;
        if (self.searchTerm)
        {
            if (dd.title && [dd.title rangeOfString:self.searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)
                existInSearch = YES;
            if (dd.details && [dd.details rangeOfString:self.searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)
                existInSearch = YES;
            if (dd.location.name && [dd.location.name rangeOfString:self.searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)
                existInSearch = YES;
        }
        
        //check filter condition
        BOOL existInFilter = filter == DDDoubleDatesViewControllerFilterNone;
        switch (filter) {
            case DDDoubleDatesViewControllerFilterCreated:
                existInFilter = [dd.relationship isEqualToString:DDDoubleDateRelationshipOwner];
                break;
            case DDDoubleDatesViewControllerFilterWing:
                existInFilter = [dd.relationship isEqualToString:DDDoubleDateRelationshipWing];
                break;
            case DDDoubleDatesViewControllerFilterAttending:
                existInFilter = ![dd.relationship isEqualToString:DDDoubleDateRelationshipOwner] && ![dd.relationship isEqualToString:DDDoubleDateRelationshipWing];
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
        return [self filteredDoubleDates:doubleDates_ filter:DDDoubleDatesViewControllerFilterNone];
    else if (mode_ == DDDoubleDatesViewControllerModeMine)
    {
        switch (section) {
            case 0:
                return [self filteredDoubleDates:doubleDates_ filter:DDDoubleDatesViewControllerFilterCreated];
                break;
            case 1:
                return [self filteredDoubleDates:doubleDates_ filter:DDDoubleDatesViewControllerFilterWing];
                break;
            case 2:
                return [self filteredDoubleDates:doubleDates_ filter:DDDoubleDatesViewControllerFilterAttending];
                break;
            default:
                break;
        }
    }
    return nil;
}

- (void)onDataRefreshed
{
    //check for both data
    if (doubleDates_)
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
    for (DDDoubleDate *d in doubleDates_)
    {
        if ([[d identifier] intValue] == [[doubleDate identifier] intValue])
            [doubleDatesToRemove addObject:d];
    }
    
    //remove
    while ([doubleDatesToRemove count])
    {
        DDDoubleDate *d = [doubleDatesToRemove lastObject];
        [doubleDates_ removeObject:d];
        [doubleDatesToRemove removeObject:d];
    }
}

- (void)updateNavigationBar
{
    //check current mode
    if (mode_ == DDDoubleDatesViewControllerModeMine)
    {
        if (self.tableView.editing)
            self.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Done", nil) target:self action:@selector(editTouched:)];
        else
            self.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Edit", nil) target:self action:@selector(editTouched:)];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Filter", nil) target:self action:@selector(filterTouched:)];
    }
}

- (void)updateSearchBar
{
    //check current mode
    if (mode_ == DDDoubleDatesViewControllerModeAll)
    {
        //create search bar
        [self setupSearchBar];
        
        //set placeholder
        [[self searchBar] setPlaceholder:NSLocalizedString(@"Search DoubleDates", nil)];
    }
    else
    {
        self.tableView.tableHeaderView = nil;
    }
}

- (void)replaceObject:(DDDoubleDate*)object inArray:(NSMutableArray*)array
{
    NSInteger index = NSNotFound;
    for (DDDoubleDate *o in array)
    {
        if (object == o)
            continue;
        if ([[object identifier] intValue] == [[o identifier] intValue])
            index = [array indexOfObject:o];
    }
    if (index != NSNotFound)
        [array replaceObjectAtIndex:index withObject:object];
}

- (void)objectUpdatedNotification:(NSNotification*)notification
{
    if ([[notification object] isKindOfClass:[DDDoubleDate class]])
    {
        [self replaceObject:[notification object] inArray:doubleDates_];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get double date
    DDDoubleDate *doubleDate = [[self doubleDatesForSection:indexPath.section] objectAtIndex:indexPath.row];

    //open view controller
    DDDoubleDateViewController *viewController = [[[DDDoubleDateViewController alloc] init] autorelease];
    viewController.doubleDate = doubleDate;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [self tableView:aTableView viewForHeaderInSection:section];
    if (headerView)
        return headerView.frame.size.height;
    return 0;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    if ([self tableView:aTableView numberOfRowsInSection:section] > 0)
    {
        if (mode_ == DDDoubleDatesViewControllerModeMine)
        {
            switch (section) {
                case 0:
                    return [self viewForHeaderWithMainText:NSLocalizedString(@"I've Created", nil) detailedText:nil];
                    break;
                case 1:
                    return [self viewForHeaderWithMainText:NSLocalizedString(@"I'm a Wing", nil) detailedText:nil];
                    break;
                case 2:
                    return [self viewForHeaderWithMainText:NSLocalizedString(@"I'm Attending", nil) detailedText:nil];
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
        cell = [[[UINib nibWithNibName:[cellClass description] bundle:nil] instantiateWithOwner:aTableView options:nil] objectAtIndex:0];
    
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
    [doubleDates_ release];
    doubleDates_ = [[NSMutableArray arrayWithArray:doubleDates] retain];
    
    //inform about completion
    [self onDataRefreshed];
}

- (void)getDoubleDatesDidFailedWithError:(NSError*)error
{
    //save friends
    [doubleDates_ release];
    doubleDates_ = [[NSMutableArray alloc] init];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
    
    //inform about completion
    [self onDataRefreshed];
}

- (void)getMyDoubleDatesSucceed:(NSArray*)doubleDates
{
    //save doubledates
    [doubleDates_ release];
    doubleDates_ = [[NSMutableArray arrayWithArray:doubleDates] retain];
    
    //inform about completion
    [self onDataRefreshed];
}

- (void)getMyDoubleDatesDidFailedWithError:(NSError*)error
{
    //save friends
    [doubleDates_ release];
    doubleDates_ = [[NSMutableArray alloc] init];
    
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
#pragma mark Refreshing

- (void)onRefresh
{
    //unset old values
    [doubleDates_ release];
    doubleDates_ = nil;
    
    //request doubledates
    if (mode_ == DDDoubleDatesViewControllerModeAll)
        [self.apiController getDoubleDatesWithFilter:self.searchFilter];
    else if (mode_ == DDDoubleDatesViewControllerModeMine)
        [self.apiController getMyDoubleDates];
}

#pragma mark -
#pragma mark DDDoubleDateFilterViewControllerDelegate
    
- (void)doubleDateFilterViewControllerDidCancel
{
    self.searchFilter = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)doubleDateFilterViewControllerDidAppliedFilter:(DDDoubleDateFilter*)filter
{
    self.searchFilter = filter;
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
