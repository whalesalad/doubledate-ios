//
//  DDCreateDoubleDateViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDCreateDoubleDateViewController.h"
#import "DDShortUser.h"
#import "DDWingsViewController.h"
#import "DDImageView.h"
#import "DDPlacemark.h"
#import "DDLocationChooserViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DDCreateDoubleDateViewController () <DDWingsViewControllerDelegate, DDLocationPickerViewControllerDelegate, DDLocationControllerDelegate>

@property(nonatomic, retain) DDShortUser *wing;
@property(nonatomic, retain) DDPlacemark *location;

@end

@implementation DDCreateDoubleDateViewController

@synthesize wing;
@synthesize location;
@synthesize buttonWing;
@synthesize buttonLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        locationController_ = [[DDLocationController alloc] init];
        locationController_.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //apply text
    self.buttonWing.placeholder = NSLocalizedString(@"Choose a wing...", nil);
    
    //apply text
    self.buttonLocation.placeholder = NSLocalizedString(@"Choose a location...", nil);
    
    //apply wing
    self.wing = self.wing;
    
    //apply location
    self.location = self.location;
    
    //force location update
    [locationController_ forceSearchPlacemarks];
}

- (void)viewDidUnload
{
    [buttonWing release], buttonWing = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    locationController_.delegate = nil;
    [locationController_ release];
    [buttonWing release];
    [buttonLocation release];
    [wing release];
    [location release];
    [super dealloc];
}

#pragma mark -
#pragma comment other

- (IBAction)wingTouched:(id)sender
{
    DDWingsViewController *wingsViewController = [[[DDWingsViewController alloc] init] autorelease];
    wingsViewController.delegate = self;
    wingsViewController.isSelectingMode = YES;
    [self.navigationController pushViewController:wingsViewController animated:YES];
}

- (IBAction)locationTouched:(id)sender
{
    DDLocationChooserViewController *locationChooserViewController = [[[DDLocationChooserViewController alloc] init] autorelease];
    locationChooserViewController.delegate = self;
    locationChooserViewController.location = locationController_.location;
    [self.navigationController pushViewController:locationChooserViewController animated:YES];
}

- (void)setWing:(DDShortUser *)v
{
    //update value
    if (wing != v)
    {
        [wing release];
        wing = [v retain];
    }
    
    //apply blank image by default
    self.buttonWing.normalIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank-wingman-icon.png"]] autorelease];
    
    //apply wing
    if (wing)
    {
        //load image
        if ([[wing photo] downloadUrl])
        {
            DDImageView *imageView = [[[DDImageView alloc] init] autorelease];
            imageView.frame = CGRectMake(0, 0, 34, 34);
            imageView.layer.cornerRadius = 17;
            imageView.layer.masksToBounds = YES;
            [imageView reloadFromUrl:[NSURL URLWithString:[[wing photo] downloadUrl]]];
            self.buttonWing.normalIcon = imageView;
        }
        
        //apply text
        self.buttonWing.text = [wing fullName];
    }
}

- (void)setLocation:(DDPlacemark *)v
{
    //update value
    if (location != v)
    {
        [location release];
        location = [v retain];
    }
    
    //apply blank image by default
    self.buttonLocation.normalIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location-icon-blank.png"]] autorelease];
    
    //apply location
    if (location)
    {
        //apply image
        self.buttonLocation.normalIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location-icon-selected.png"]] autorelease];
        
        //set location text
        self.buttonLocation.text = [location name];
    }
}

#pragma mark -
#pragma comment DDWingsViewControllerDelegate

- (void)wingsViewController:(DDWingsViewController*)viewController didSelectUser:(DDShortUser*)user
{
    [self setWing:user];
    [viewController.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma comment DDLocationPickerViewControllerDelegate

- (void)locationPickerViewControllerDidFoundPlacemarks:(NSArray*)placemarks
{
    [self setLocation:[placemarks objectAtIndex:0]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)locationPickerViewControllerDidCancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma comment DDLocationControllerDlegate

- (void)locationManagerDidFoundLocation:(CLLocation*)location
{
    
}

- (void)locationManagerDidFailedWithError:(NSError*)error
{
    //remove loading
    self.buttonLocation.normalIcon = nil;
    self.buttonLocation.selectedIcon = nil;
    
    //updat text
    self.buttonLocation.placeholder = NSLocalizedString(@"Failed to find location", nil);
    
    //disable button
    self.buttonLocation.enabled = NO;
}

- (BOOL)locationManagerShouldGeoDecodeLocation:(CLLocation*)location
{
    return NO;
}

- (void)locationManagerDidFoundPlacemarks:(NSArray*)placemarks
{
}

@end
