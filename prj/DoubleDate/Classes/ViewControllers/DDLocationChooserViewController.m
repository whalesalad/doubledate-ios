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

@interface DDLocationChooserViewController ()<DDAPIControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation DDLocationChooserViewController

@synthesize delegate;
@synthesize location;
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        apiController_ = [[DDAPIController alloc] init];
        apiController_.delegate = self;
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
        [apiController_ searchPlacemarksForLatitude:self.location.coordinate.latitude longitude:location.coordinate.longitude];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Location", nil);
    
    //add left button
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancelTouched:)] autorelease];
    
    //unset background color of the table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [tableView release], tableView = nil;
}

- (void)dealloc
{
    [location release];
    [placemarks_ release];
    apiController_.delegate = nil;
    [apiController_ release];
    [tableView release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate locationPickerViewControllerDidFoundPlacemarks:[NSArray arrayWithObject:[placemarks_ objectAtIndex:indexPath.row]]];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Nearby Locations", nil);
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [placemarks_ count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [[[self class] description] stringByAppendingString:@"Cell"];
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell.textLabel.text = [[placemarks_ objectAtIndex:indexPath.row] name];
    cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location-marker.png"]] autorelease];
    return cell;
}

#pragma mark -
#pragma comment DDAPIControllerDelegate

- (void)searchPlacemarksSucceed:(NSArray*)placemarks
{
    //hide hud
    [self hideHud:YES];
    
    //save placemarks
    [placemarks_ release];
    placemarks_ = [placemarks retain];
    
    //reload the table
    [self.tableView reloadData];
}

- (void)searchPlacemarksDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma comment other

- (void)cancelTouched:(id)sender
{
    [self.delegate locationPickerViewControllerDidCancel];
}

@end
