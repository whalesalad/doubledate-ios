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
#import "DDTools.h"
#import "DDAPIController.h"
#import "DDMaxActivitiesPayload.h"
#import "DDUnlockAlertView.h"
#import "DDAppDelegate.h"
#import "DDAuthenticationController.h"
#import "DDObjectsController.h"
#import <QuartzCore/QuartzCore.h>

#define kTableViewContentInset UIEdgeInsetsMake(0, 0, 3, 0)

#define kEarnCost 50

typedef enum
{
    DDDoubleDatesViewControllerFilterNone,
    DDDoubleDatesViewControllerFilterCreated,
    DDDoubleDatesViewControllerFilterWing,
    DDDoubleDatesViewControllerFilterAttending,
} DDDoubleDatesViewControllerFilter;

@interface DDDoubleDatesViewController () <UITableViewDataSource, UITableViewDelegate, DDDoubleDateFilterViewControllerDelegate, DDUnlockAlertViewDelegate>

@property(nonatomic, retain) UIView *unlockTopView;
@property(nonatomic, retain) DDMaxActivitiesPayload *maxActivitiesPayload;
@property(nonatomic, assign) NSInteger unlockCost;

- (NSArray*)doubleDatesForSection:(NSInteger)section;
- (void)onDataRefreshed;
- (void)removeDoubleDate:(DDDoubleDate*)doubleDate;
- (void)updateNavigationBar;
- (void)updateSearchBar;
- (void)updateUnlockView;

@end

@implementation DDDoubleDatesViewController

@synthesize unlockTopView;
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

- (void)reloadData
{
    //show/hide unlock view
    [self updateUnlockView];
    
    //reload table
    [self.tableView reloadData];
    
    //update no data view
    [self updateNoDataView];
}

- (UIButton*)newBaseButtonWithImage:(UIImage*)image
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    button.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.2f];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 0);
    return button;
}

- (UIButton*)newAddButton
{
    UIImage *image = [UIImage imageNamed:@"btn-blue-create.png"];
    UIButton *ret = [self newBaseButtonWithImage:image];
    [ret addTarget:self action:@selector(plusTouched:) forControlEvents:UIControlEventTouchUpInside];
    [ret setTitle:NSLocalizedString(@"Create a DoubleDate", nil) forState:UIControlStateNormal];
    return ret;
}

- (UIButton*)newUnlockButton
{
    UIImage *image = [UIImage imageNamed:@"btn-yellow-unlock.png"];
    UIButton *ret = [self newBaseButtonWithImage:image];
    [ret addTarget:self action:@selector(unlockTouched:) forControlEvents:UIControlEventTouchUpInside];
    return ret;
}

- (void)customizeNoDataView
{
    //add create date button
    UIButton *buttonCreateDate = [self newAddButton];
    buttonCreateDate.center = CGPointMake(self.viewNoData.frame.size.width/2, self.viewNoData.frame.size.height/2);
    [self.viewNoData addSubview:buttonCreateDate];
    
    //add label
    UILabel *labelTop = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)] autorelease];
    labelTop.center = CGPointMake(buttonCreateDate.center.x, buttonCreateDate.center.y - 82);
    labelTop.numberOfLines = 2;
    labelTop.text = NSLocalizedString(@"You haven't created any dates yet.\nWhat are you waiting for?", nil);
    
    //add label
    UILabel *labelBottom = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)] autorelease];
    labelBottom.center = CGPointMake(buttonCreateDate.center.x, buttonCreateDate.center.y + 24);
    [self customizeGenericLabel:labelTop];
    [self.viewNoData addSubview:labelTop];

    NSString *format = NSLocalizedString(@"Earn %d coins every time you post.", nil);
    labelBottom.text = [NSString stringWithFormat:format, kEarnCost];
    [self customizeGenericLabel:labelBottom];
    [self.viewNoData addSubview:labelBottom];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //customize separators
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //add slight padding to end of view.
    self.tableView.contentInset = kTableViewContentInset;
    
    //add unlock view to the top
    self.unlockTopView = [[[UIView alloc] initWithFrame:CGRectMake(0, -88, 320, 88)] autorelease];
    self.unlockTopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-doubledates-upper.png"]];
    
//    self.unlockTopView
    self.unlockTopView.hidden = YES;
    [self.tableView addSubview:self.unlockTopView];
    
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check for first time
    if (!requestDoubleDatesAll_ && !requestDoubleDatesMine_ && !requestMeUnlockMaxActivities_)
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

- (void)unlockTouched:(id)sender
{
    DDUnlockAlertViewFullScreen *alert = [[[DDUnlockAlertViewFullScreen alloc] init] autorelease];
    alert.price = abs([self.maxActivitiesPayload.cost intValue]);
    alert.title = [self.maxActivitiesPayload title];
    alert.message = [self.maxActivitiesPayload description];
    alert.delegate = self;
    [alert show];
}

- (void)plusTouched:(id)sender
{
    DDCreateDoubleDateViewController *viewController = [[[DDCreateDoubleDateViewController alloc] init] autorelease];
    viewController.doubleDatesViewController = self;
    [self.navigationController presentViewController:[[[UINavigationController alloc] initWithRootViewController:viewController] autorelease] animated:YES completion:^{
    }];
}

- (void)filterTouched:(id)sender
{
    DDDoubleDateFilterViewController *viewController = [[[DDDoubleDateFilterViewController alloc] initWithFilter:self.searchFilter] autorelease];
    viewController.delegate = self;
    [self.navigationController presentViewController:[[[UINavigationController alloc] initWithRootViewController:viewController] autorelease] animated:YES completion:^{
    }];
}

- (void)segmentedControlTouched:(UISegmentedControl*)sender
{
    //update mode
    if (sender.selectedSegmentIndex == 0)
        mode_ = DDDoubleDatesViewControllerModeAll;
    else
        mode_ = DDDoubleDatesViewControllerModeMine;
    
    //reload data
    [self reloadData];
    
    //update navigation bar
    [self updateNavigationBar];
    
    //update search bar
    [self updateSearchBar];
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
    if (![self.apiController isRequestExist:requestDoubleDatesAll_] && ![self.apiController isRequestExist:requestDoubleDatesMine_] && ![self.apiController isRequestExist:requestMeUnlockMaxActivities_])
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
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Filter", nil) target:self action:@selector(filterTouched:)];
    }
    
    //set names for segmented control items
    NSString *exploreName = NSLocalizedString(@"Explore", nil);
    NSString *myDatesName = NSLocalizedString(@"My Dates", nil);
    
    //create segmented control
    if (![self.navigationItem.titleView isKindOfClass:[UISegmentedControl class]])
    {
        //add segmeneted control
        NSMutableArray *items = [NSMutableArray array];
        [items addObject:[DDSegmentedControlItem itemWithTitle:exploreName width:0]];
        [items addObject:[DDSegmentedControlItem itemWithTitle:myDatesName width:0]];
        DDSegmentedControl *segmentedControl = [[[DDSegmentedControl alloc] initWithItems:items style:DDSegmentedControlStyleSmall] autorelease];
        self.navigationItem.titleView = segmentedControl;
        segmentedControl.selectedSegmentIndex = 0;
        [segmentedControl addTarget:self action:@selector(segmentedControlTouched:) forControlEvents:UIControlEventValueChanged];
    }
    
    //update mode
    [(UISegmentedControl*)self.navigationItem.titleView setSelectedSegmentIndex:(mode_ == DDDoubleDatesViewControllerModeMine)?1:0];
    
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

- (void)updateUnlockView
{
    //update visibility of unlock view
    self.unlockTopView.hidden = (mode_ == DDDoubleDatesViewControllerModeAll) || ([doubleDatesMine_ count] == 0);
    UIEdgeInsets contentInsetBefore = self.tableView.contentInset;
    self.tableView.contentInset = UIEdgeInsetsMake(kTableViewContentInset.top+self.unlockTopView.hidden?0:self.unlockTopView.frame.size.height, kTableViewContentInset.left, kTableViewContentInset.bottom, kTableViewContentInset.right);
    self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y - self.tableView.contentInset.top + contentInsetBefore.top);
    [self scrollViewDidScroll:self.tableView];
    
    //check if no hidden
    if (!self.unlockTopView.hidden)
    {
        //customize view
        while ([[self.unlockTopView subviews] count])
            [[[self.unlockTopView subviews] lastObject] removeFromSuperview];
        
        //add label
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 8, 320, 24)] autorelease];
        [self customizeGenericLabel:label];
        
        //add button
        UIButton *button = nil;        [self customizeGenericLabel:label];
        
        //we are able to add new activity here
        if (![self.maxActivitiesPayload.unlockRequired boolValue])
        {
            //set text
            NSString *format = NSLocalizedString(@"Post up to %d dates at the same time", nil);
            label.text = [NSString stringWithFormat:format, [self.maxActivitiesPayload.activitiesAllowed intValue]];

            //set button
            button = [self newAddButton];
            button.center = CGPointMake(self.unlockTopView.frame.size.width/2, self.unlockTopView.frame.size.height/2+16);
        }
        else
        {
            //set text
            NSString *textFormat = NSLocalizedString(@"You've posted your maximum of %d dates!", nil);
            label.text = [NSString stringWithFormat:textFormat, [self.maxActivitiesPayload.activitiesAllowed intValue]];
            label.textColor = [UIColor colorWithRed:236.0f/255.0f green:165.0f/255.0f blue:26.0f/255.0f alpha:1];
            
            //set button
            button = [self newUnlockButton];
            NSString *buttonFormat = NSLocalizedString(@"Unlock %d DoubleDates", nil);
            [button setTitle:[NSString stringWithFormat:buttonFormat, [self.maxActivitiesPayload.maxActivities intValue]] forState:UIControlStateNormal];
            button.center = CGPointMake(self.unlockTopView.frame.size.width/2, self.unlockTopView.frame.size.height/2+15);
        }
        
        //add views
        if (button)
            [self.unlockTopView addSubview:button];
        
        if (label)
            [self.unlockTopView addSubview:label];
    
    }
}

- (void)customizeGenericLabel:(UILabel*)label
{
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
    label.textColor = [UIColor colorWithWhite:0.8f alpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.shadowOffset = CGSizeMake(0, 1);
    label.layer.shadowOpacity = 1.0f;
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowRadius = 1;
    label.layer.masksToBounds = NO;
}

- (void)updateNoDataView
{
    if (doubleDatesMine_ && (mode_ == DDDoubleDatesViewControllerModeMine))
        [super updateNoDataView];
    else
        self.viewNoData.hidden = YES;
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
            requestMeUnlockMaxActivities_ = 0;
        }
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
    viewController.backButtonTitle = self.navigationItem.title;
    [self.navigationController pushViewController:viewController animated:YES];
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

- (void)getMeUnlockMaxActivitiesSucceed:(DDMaxActivitiesPayload *)payload
{
    //save data
    self.maxActivitiesPayload = payload;
    
    //inform about completion
    [self performSelector:@selector(onDataRefreshed) withObject:nil afterDelay:0];
}

- (void)getMeUnlockMaxActivitiesDidFailedWithError:(NSError *)error
{
    //save data
    self.maxActivitiesPayload = nil;
    
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

- (void)unlockMeMaxActivitiesSucceed:(DDMaxActivitiesPayload*)payload
{
    //hide hud
    [self hideHud:YES];
        
    //update total coins
    NSInteger totalCoins = [[[DDAuthenticationController currentUser] totalCoins] intValue] + self.unlockCost;
    [[DDAuthenticationController currentUser] setTotalCoins:[NSNumber numberWithInt:totalCoins]];
    
    //inform about change
    [[NSNotificationCenter defaultCenter] postNotificationName:DDObjectsControllerDidUpdateObjectNotification object:[DDAuthenticationController currentUser]];
    
    //update payload
    self.maxActivitiesPayload = payload;
    
    //update unlock view
    [self updateUnlockView];
}

- (void)unlockMeMaxActivitiesDidFailedWithError:(NSError*)error
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
    //request doubledates
    requestDoubleDatesAll_ = [self.apiController getDoubleDatesWithFilter:self.searchFilter];
    requestDoubleDatesMine_ = [self.apiController getMyDoubleDates];
    requestMeUnlockMaxActivities_ = [self.apiController getMeUnlockMaxActivities];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -self.unlockTopView.frame.size.height)
    {
        self.unlockTopView.frame = CGRectMake(0, -self.unlockTopView.frame.size.height, self.unlockTopView.frame.size.width, self.unlockTopView.frame.size.height);
    }
    else
    {
        self.unlockTopView.frame = CGRectMake(0, scrollView.contentOffset.y, self.unlockTopView.frame.size.width, self.unlockTopView.frame.size.height);
    }
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

#pragma mark -
#pragma mark DDUnlockAlertViewDelegate

- (void)unlockAlertViewDidCancel:(DDUnlockAlertView*)sender
{
}

- (void)unlockAlertViewDidUnlock:(DDUnlockAlertView*)sender
{
    //show loading
    [self showHudWithText:NSLocalizedString(@"Unlocking", nil) animated:YES];
    
    //save cost of unlock
    self.unlockCost = [self.maxActivitiesPayload.cost intValue];
        
    //unlock
    [self.apiController unlockMeMaxActivities:self.maxActivitiesPayload];
}

@end
