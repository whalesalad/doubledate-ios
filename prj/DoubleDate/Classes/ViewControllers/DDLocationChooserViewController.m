//
//  DDLocationChooserViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/24/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDLocationChooserViewController.h"
#import "DDTableViewController+Refresh.h"
#import "UIViewController+Design.h"
#import "DDAPIController.h"
#import "DDPlacemark.h"
#import "DDBarButtonItem.h"
#import "DDLocationTableViewCell.h"
#import "DDPlacemark.h"
#import "DDSearchBar.h"
#import "DDTools.h"

@interface DDLocationChooserViewController ()<DDAPIControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property(nonatomic, readonly) UISearchBar *searchBar;
@property(nonatomic, readonly) UITableView *tableView;

@end

@implementation DDLocationChooserViewController

@synthesize delegate;
@synthesize ddLocation;
@synthesize clLocation;
@synthesize options;
@synthesize allowsMultiplyChoice;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        selectedLocations_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    //make for supper
    [super viewDidAppear:animated];
    
    //check if we need to make a request
    if (!placemarks_)
        [self startRefreshWithText:NSLocalizedString(@"Loading", nil)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Location", nil);
    
    //set header as search bar
    DDSearchBar *searchBar = [[[DDSearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    searchBar.delegate = self;
    searchBar.placeholder = NSLocalizedString(@"All locations", nil);
    self.tableView.tableHeaderView = searchBar;
    
    //move header
    self.tableView.contentOffset = CGPointMake(0, searchBar.frame.size.height);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)setDdLocation:(DDPlacemark *)v
{
    if (v != ddLocation)
    {
        [ddLocation release];
        ddLocation = [v retain];
    }
    [selectedLocations_ removeAllObjects];
    if (ddLocation)
        [selectedLocations_ addObject:ddLocation];
}

- (void)setClLocation:(CLLocation *)v
{
    if (v != clLocation)
    {
        [clLocation release];
        clLocation = [v retain];
    }
}

- (BOOL)isLocationSelected:(DDPlacemark *)placemark
{
    for (DDPlacemark *l in selectedLocations_)
    {
        if ([[l identifier] intValue] > 0 && [[l identifier] intValue] == [[placemark identifier] intValue])
            return YES;
    }
    return NO;
}

- (DDLocationSearchOptions)optionForSection:(NSInteger)section
{
    if (self.options == DDLocationSearchOptionsBoth)
    {
        if (section == 0)
            return DDLocationSearchOptionsVenues;
        return DDLocationSearchOptionsCities;
    }
    return self.options;
}

- (NSArray*)locationsForSection:(NSInteger)section
{
    NSMutableArray *ret = [NSMutableArray array];
    for (DDPlacemark *loc in placemarks_)
    {
        BOOL isVenue = [[loc type] isEqualToString:DDPlacemarkTypeVenue];
        BOOL venueRequired = [self optionForSection:section] == DDLocationSearchOptionsVenues;
        BOOL existInSearch = [self.searchBar.text length] == 0;
        if (self.searchBar.text)
        {
            if (loc.name && [loc.name rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch].location != NSNotFound)
                existInSearch = YES;
            if (loc.locationName && [loc.locationName rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch].location != NSNotFound)
                existInSearch = YES;
            if (loc.address && [loc.address rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch].location != NSNotFound)
                existInSearch = YES;
        }
        if (isVenue == venueRequired && existInSearch)
            [ret addObject:loc];
    }
    return ret;
}

- (UISearchBar*)searchBar
{
    return (UISearchBar*)self.tableView.tableHeaderView;
}

- (void)dealloc
{
    [ddLocation release];
    [clLocation release];
    [placemarks_ release];
    [selectedLocations_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //save location
    DDPlacemark *selectedLocation = [(DDLocationTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath] location];
    
    //remove from selected list
    if ([selectedLocations_ containsObject:selectedLocation])
        [selectedLocations_ removeObject:selectedLocation];
    else
    {
        if (!self.allowsMultiplyChoice)
            [selectedLocations_ removeAllObjects];
        [selectedLocations_ addObject:selectedLocation];
    }
    
    //reload the cell
    [aTableView reloadData];
    
    //inform delegate
    [self.delegate locationPickerViewControllerDidFoundPlacemarks:[NSArray arrayWithObject:selectedLocation]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DDLocationTableViewCell height];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    return [[self tableView:aTableView viewForHeaderInSection:section] frame].size.height;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    if ([self optionForSection:section] == DDLocationSearchOptionsCities)
    {
        return [self viewForHeaderWithMainText:NSLocalizedString(@"CITIES", nil) detailedText:nil];
    }
    else if ([self optionForSection:section] == DDLocationSearchOptionsVenues)
    {
        return [self viewForHeaderWithMainText:NSLocalizedString(@"VENUES", nil) detailedText:NSLocalizedString(@"POWERED BY FOURSQUARE", nil)];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [[self locationsForSection:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (placemarks_ == nil)
        return 0;
    if (self.options == DDLocationSearchOptionsBoth)
        return 2;
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //save location
    DDPlacemark *selectedLocation = nil;
    if (indexPath.row < [[self locationsForSection:indexPath.section] count])
        selectedLocation = [[self locationsForSection:indexPath.section] objectAtIndex:indexPath.row];
    
    //create cell of needed type
    NSString *identifier = [[[self class] description] stringByAppendingString:@"DDLocationTableViewCell"];
    UITableViewCellStyle cellStyle = UITableViewCellStyleDefault;
    if ([self optionForSection:indexPath.section] == DDLocationSearchOptionsVenues)
        cellStyle = UITableViewCellStyleSubtitle;
    DDLocationTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
        cell = [[[DDLocationTableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:nil] autorelease];
    
    //apply needed cell design
    [cell applyGroupedBackgroundStyleForTableView:aTableView withIndexPath:indexPath];

    //set cell location
    cell.location = selectedLocation;
    
    //update selected ui
    if ([self isLocationSelected:cell.location])
        cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]] autorelease];
    else
        cell.accessoryView = nil;
    
    return cell;
}

#pragma mark -
#pragma mark DDAPIControllerDelegate

- (void)searchPlacemarksSucceed:(NSArray*)placemarks
{
    //hide refresh UI
    [self finishRefresh];
    
    //save placemarks
    [placemarks_ release];
    placemarks_ = [placemarks retain];
    
    //reload the table
    [self.tableView reloadData];
}

- (void)searchPlacemarksDidFailedWithError:(NSError*)error
{
    //hide refresh UI
    [self finishRefresh];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

#pragma mark -
#pragma mark Refreshing

- (void)onRefresh
{
    //search for placemarks
    CGFloat latitude = 0;
    CGFloat longitude = 0;
    if (self.ddLocation)
    {
        latitude = [self.ddLocation.latitude floatValue];
        longitude = [self.ddLocation.longitude floatValue];
    }
    else if (self.clLocation)
    {
        latitude = self.clLocation.coordinate.latitude;
        longitude = self.clLocation.coordinate.longitude;
    }
    [self.apiController searchPlacemarksForLatitude:latitude longitude:longitude options:self.options];
}

@end
