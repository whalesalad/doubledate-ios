//
//  DDLocationChooserViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/24/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDLocationChooserViewController.h"
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
    {
        //show hud
        [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
        
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Location", nil);
    
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
    searchBar.placeholder = NSLocalizedString(@"All locations", nil);
    tableView_.tableHeaderView = searchBar;
    
    //move header
    tableView_.contentOffset = CGPointMake(0, searchBar.frame.size.height);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [tableView_ release], tableView_ = nil;
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
    return (UISearchBar*)tableView_.tableHeaderView;
}

- (UITableView*)tableView
{
    return tableView_;
}

- (void)dealloc
{
    [ddLocation release];
    [clLocation release];
    [placemarks_ release];
    [tableView_ release];
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
    DDPlacemark *selectedLocation = [[self locationsForSection:indexPath.section] objectAtIndex:indexPath.row];
    
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
    //hide hud
    [self hideHud:YES];
    
    //save placemarks
    [placemarks_ release];
    placemarks_ = [placemarks retain];
    
    //reload the table
    [tableView_ reloadData];
}

- (void)searchPlacemarksDidFailedWithError:(NSError*)error
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
