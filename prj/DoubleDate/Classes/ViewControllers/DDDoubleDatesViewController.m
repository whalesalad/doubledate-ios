//
//  DDDoubleDatesViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
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
#import "DDTools.h"
#import "DDAPIController.h"
#import "DDUnlockAlertView.h"
#import "DDAppDelegate.h"
#import "DDAuthenticationController.h"
#import "DDObjectsController.h"
#import "UIView+Other.h"
#import "DDAppDelegate+NavigationMenu.h"
#import <QuartzCore/QuartzCore.h>

#define kEarnCost 50

#define kTagNoDataExplore 1
#define kTagNoDataMine 2

#define kGetFilterLocationNotification @"gfln"
#define kCurrentFilterPlacemarkObject @"location_object"

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

@synthesize searchFilter;
@synthesize mode = mode_;

+ (NSString*)filterCityName
{
    DDPlacemark *placemark = [DDLocationController currentLocationController].lastPlacemark;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetFilterLocationNotification object:nil userInfo:userInfo];
    if ([[userInfo objectForKey:kCurrentFilterPlacemarkObject] isKindOfClass:[DDPlacemark class]])
        placemark = (DDPlacemark*)[userInfo objectForKey:kCurrentFilterPlacemarkObject];
    if (placemark)
        return placemark.locality;
    return @"";
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        mode_ = DDDoubleDatesViewControllerModeAll;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectUpdatedNotification:) name:DDObjectsControllerDidUpdateObjectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFilterLocationNotification:) name:kGetFilterLocationNotification object:nil];
    }
    return self;
}

- (void)reloadData
{
    //reload table
    [self.tableView reloadData];
    
    //update no data view
    [self updateNoDataView];
}

- (UIButton*)newAddButton
{
    UIImage *image = [UIImage imageNamed:@"btn-blue-create.png"];
    UIButton *ret = [self.view baseButtonWithImage:image];
    [ret addTarget:self action:@selector(plusTouched:) forControlEvents:UIControlEventTouchUpInside];
    [ret setTitle:NSLocalizedString(@"Create a DoubleDate", nil) forState:UIControlStateNormal];
    return ret;
}

- (void)customizeNoDataView
{
    //mine
    {
        UIView *viewMine = [[[UIView alloc] initWithFrame:self.viewNoData.bounds] autorelease];
        viewMine.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        viewMine.tag = kTagNoDataMine;
        viewMine.hidden = YES;
        [self.viewNoData addSubview:viewMine];
        
        //customize
        [viewMine applyNoDataWithMainText:NSLocalizedString(@"You haven't created any\nDoubleDates.", @"Main text of no data in MINE dates") infoText:nil];
    }
    
    //explore
    {
        UIView *viewExplore = [[[UIView alloc] initWithFrame:self.viewNoData.bounds] autorelease];
        viewExplore.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        viewExplore.tag = kTagNoDataExplore;
        viewExplore.hidden = YES;
        [self.viewNoData addSubview:viewExplore];
        
        //customize
        [viewExplore applyNoDataWithMainText:NSLocalizedString(@"There aren't any\nDoubleDates nearby.", @"Main text of no data in EXPLORE dates")
                                    infoText:[NSString stringWithFormat:NSLocalizedString(@"Be first to create a DoubleDate\nnearby and earn %d coins.", @"Detailed text of no data in EXPLORE dates"), kEarnCost]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //customize separators
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //update navigation bar
    [self updateNavigationBar];
    
    //update search bar
    [self updateSearchBar];
    
    //customize no data view
    [self customizeNoDataView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //update navigation bar
    [self updateNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check for first time
    if (!requestDoubleDatesAll_ && !requestDoubleDatesMine_)
        [self startRefreshWithText:NSLocalizedString(@"Loading", nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [doubleDatesAll_ release];
    [doubleDatesMine_ release];
    [searchFilter release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (void)plusTouched:(id)sender
{
    [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] dismissNavigationMenu];
    
    DDCreateDoubleDateViewController *viewController = [[[DDCreateDoubleDateViewController alloc] init] autorelease];
    [self.navigationController presentViewController:[[[UINavigationController alloc] initWithRootViewController:viewController] autorelease] animated:YES completion:^{
    }];
}

- (void)filterTouched:(id)sender
{
    [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] dismissNavigationMenu];
    
    DDDoubleDateFilterViewController *viewController = [[[DDDoubleDateFilterViewController alloc] initWithFilter:self.searchFilter] autorelease];
    viewController.delegate = self;
    [self.navigationController presentViewController:[[[UINavigationController alloc] initWithRootViewController:viewController] autorelease] animated:YES completion:^{
    }];
}

- (NSArray*)filteredDoubleDates:(NSArray*)doubleDates filter:(DDDoubleDatesViewControllerFilter)filter
{
    NSMutableArray *ret = [NSMutableArray array];
    
    //filter doubledates
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
    
    //arrange by updated at flag
    NSMutableArray *sortedRet = [NSMutableArray arrayWithArray:ret];
    [sortedRet sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        assert([obj1 isKindOfClass:[DDDoubleDate class]]);
        assert([obj2 isKindOfClass:[DDDoubleDate class]]);
        NSDate *date1 = [(DDDoubleDate*)obj1 updatedAt];
        NSDate *date2 = [(DDDoubleDate*)obj2 updatedAt];
        return [date2 compare:date1];
    }];
    
    return sortedRet;
}

- (NSArray*)doubleDatesForSection:(NSInteger)section
{
    if (mode_ == DDDoubleDatesViewControllerModeAll)
        return [self filteredDoubleDates:doubleDatesAll_ filter:DDDoubleDatesViewControllerFilterNone];
    else if (mode_ == DDDoubleDatesViewControllerModeMine)
    {
        switch (section) {
            case 0:
                return [self filteredDoubleDates:doubleDatesMine_ filter:DDDoubleDatesViewControllerFilterCreated];
                break;
            case 1:
                return [self filteredDoubleDates:doubleDatesMine_ filter:DDDoubleDatesViewControllerFilterWing];
                break;
            case 2:
                return [self filteredDoubleDates:doubleDatesMine_ filter:DDDoubleDatesViewControllerFilterAttending];
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
    if (![self.apiController isRequestExist:requestDoubleDatesAll_] && ![self.apiController isRequestExist:requestDoubleDatesMine_])
    {
        //hide hud
        [self hideHud:YES];
        
        //make super
        [self finishRefresh];
        
        //reload data
        [self reloadData];
    }
}

- (void)removeDoubleDate:(DDDoubleDate*)doubleDate
{
    //init array
    NSMutableArray *doubleDatesToRemove = [NSMutableArray array];
    
    //add from all doubledates
    for (DDDoubleDate *d in doubleDatesAll_)
    {
        if ([[d identifier] intValue] == [[doubleDate identifier] intValue])
            [doubleDatesToRemove addObject:d];
    }
    for (DDDoubleDate *d in doubleDatesMine_)
    {
        if ([[d identifier] intValue] == [[doubleDate identifier] intValue])
            [doubleDatesToRemove addObject:d];
    }
    
    //remove
    while ([doubleDatesToRemove count])
    {
        DDDoubleDate *d = [doubleDatesToRemove lastObject];
        [doubleDatesAll_ removeObject:d];
        [doubleDatesMine_ removeObject:d];
        [doubleDatesToRemove removeObject:d];
    }
}

- (void)updateNavigationBar
{
    //check current mode
    if (mode_ == DDDoubleDatesViewControllerModeMine)
    {
        self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"dd-button-add-icon.png"] target:self action:@selector(plusTouched:)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Filter", @"Text for filter doubledates button") target:self action:@selector(filterTouched:)];
    }
    
    //set names for segmented control items
    NSString *city = [[self class] filterCityName];
    NSString *exploreName = [NSString stringWithFormat:NSLocalizedString(@"Explore %@", @"Explore navigation bar of dates view"), city?city:@""];
    NSString *myDatesName = NSLocalizedString(@"DoubleDates", @"My dates navigation bar of dates view");
    
    //update navigation item
    self.navigationItem.title = (mode_ == DDDoubleDatesViewControllerModeMine)?myDatesName:exploreName;
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

- (void)updateNoDataView
{
    [super updateNoDataView];
    [[self.viewNoData viewWithTag:kTagNoDataExplore] setHidden:mode_ != DDDoubleDatesViewControllerModeAll];
    [[self.viewNoData viewWithTag:kTagNoDataMine] setHidden:mode_ != DDDoubleDatesViewControllerModeMine];
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
    //save request method
    RKRequestMethod method = [[[notification userInfo] objectForKey:DDObjectsControllerDidUpdateObjectRestKitMethodUserInfoKey] intValue];
    
    //check object
    if ([[notification object] isKindOfClass:[DDDoubleDate class]])
    {
        //check method
        if (method == RKRequestMethodGET)
        {
            //just update the object in the list
            [self replaceObject:[notification object] inArray:doubleDatesAll_];
            [self replaceObject:[notification object] inArray:doubleDatesMine_];
            
            //reload the table
            [self.tableView reloadData];
        }
        else if (method == RKRequestMethodPOST)
        {
            //add object
            [doubleDatesAll_ addObject:[notification object]];
            [doubleDatesMine_ addObject:[notification object]];
            
            //reload the whole data
            [self reloadData];
            
            //refresh
            requestDoubleDatesAll_ = 0;
            requestDoubleDatesMine_ = 0;
        }
    }
}

- (void)getFilterLocationNotification:(NSNotification*)notification
{
    if (mode_ == DDDoubleDatesViewControllerModeAll)
    {
        if ([notification.userInfo isKindOfClass:[NSMutableDictionary class]])
        {
            DDPlacemark *location = [self filterToApply].location;
            if (location)
                [(NSMutableDictionary*)notification.userInfo setObject:location forKey:kCurrentFilterPlacemarkObject];
        }
    }
}

- (DDDoubleDateFilter*)filterToApply
{
    DDDoubleDateFilter *filter = [[self.searchFilter copy] autorelease];
    if (!filter)
        filter = [[[DDDoubleDateFilter alloc] init] autorelease];
    if (!filter.location)
        filter.location = [DDLocationController currentLocationController].lastPlacemark;
    return filter;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //hide search
    if ([self.searchBar.textField isFirstResponder])
        [self.searchBar.textField resignFirstResponder];
    
    //get double date
    DDDoubleDate *doubleDate = [[self doubleDatesForSection:indexPath.section] objectAtIndex:indexPath.row];
    
    //show hud
    [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
    
    //get full information
    [self.apiController getDoubleDate:doubleDate];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    //    UIView *headerView = [self tableView:aTableView viewForHeaderInSection:section];
    //    if (headerView)
    //        return headerView.frame.size.height;
    return 0;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    //    if ([self tableView:aTableView numberOfRowsInSection:section] > 0)
    //    {
    //        if (mode_ == DDDoubleDatesViewControllerModeMine)
    //        {
    //            switch (section) {
    //                case 0:
    //                    return [self viewForHeaderWithMainText:NSLocalizedString(@"I've Created", nil) detailedText:nil];
    //                    break;
    //                case 1:
    //                    return [self viewForHeaderWithMainText:NSLocalizedString(@"I'm a Wing", nil) detailedText:nil];
    //                    break;
    //                case 2:
    //                    return [self viewForHeaderWithMainText:NSLocalizedString(@"I'm Attending", nil) detailedText:nil];
    //                    break;
    //                default:
    //                    break;
    //            }
    //        }
    //    }
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
        
        //reload data
        [self reloadData];
        
        //request delete doubledate
        [self.apiController requestDeleteDoubleDate:doubleDate];
        
        //release object
        [doubleDate release];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    if (mode_ == DDDoubleDatesViewControllerModeMine)
    //        return 3;
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
    [doubleDatesAll_ release];
    doubleDatesAll_ = [[NSMutableArray arrayWithArray:doubleDates] retain];
    
    //inform about completion
    [self performSelector:@selector(onDataRefreshed) withObject:nil afterDelay:0];
}

- (void)getDoubleDatesDidFailedWithError:(NSError*)error
{
    //save friends
    [doubleDatesAll_ release];
    doubleDatesAll_ = [[NSMutableArray alloc] init];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
    
    //inform about completion
    [self performSelector:@selector(onDataRefreshed) withObject:nil afterDelay:0];
}

- (void)getMyDoubleDatesSucceed:(NSArray*)doubleDates
{
    //save doubledates
    [doubleDatesMine_ release];
    doubleDatesMine_ = [[NSMutableArray arrayWithArray:doubleDates] retain];
    
    //inform about completion
    [self performSelector:@selector(onDataRefreshed) withObject:nil afterDelay:0];
}

- (void)getMyDoubleDatesDidFailedWithError:(NSError*)error
{
    //save friends
    [doubleDatesMine_ release];
    doubleDatesMine_ = [[NSMutableArray alloc] init];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
    
    //inform about completion
    [self performSelector:@selector(onDataRefreshed) withObject:nil afterDelay:0];
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

- (void)getDoubleDateSucceed:(DDDoubleDate*)doubleDate
{
    //hide hud
    [self hideHud:YES];
    
    //open view controller
    DDDoubleDateViewController *viewController = [[[DDDoubleDateViewController alloc] init] autorelease];
    viewController.doubleDate = doubleDate;
    viewController.backButtonTitle = self.navigationItem.title;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)getDoubleDateDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma mark Refreshing

- (void)onRefresh
{
    //apply current location if search location is not set up
    DDDoubleDateFilter *filter = [self filterToApply];
    
    //request doubledates
    requestDoubleDatesAll_ = [self.apiController getDoubleDatesWithFilter:filter];
    requestDoubleDatesMine_ = [self.apiController getMyDoubleDates];
}

#pragma mark -
#pragma mark DDDoubleDateFilterViewControllerDelegate

- (void)doubleDateFilterViewControllerDidCancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)doubleDateFilterViewControllerDidAppliedFilter:(DDDoubleDateFilter*)filter
{
    self.searchFilter = filter;
    [self startRefreshWithText:NSLocalizedString(@"Loading", nil)];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
