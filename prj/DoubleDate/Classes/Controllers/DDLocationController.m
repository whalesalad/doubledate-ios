//
//  DDLocationController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDLocationController.h"
#import "DDPlacemark.h"

@interface DDLocationController ()<CLLocationManagerDelegate, DDAPIControllerDelegate>

@end

@implementation DDLocationController

@synthesize delegate;
@synthesize lastLocation = location_;
@synthesize errorLocation = errorLocation_;
@synthesize lastPlacemark = placemark_;
@synthesize errorPlacemark = errorPlacemark_;

static DDLocationController *_sharedLocationController = nil;

+ (DDLocationController*)currentLocationController
{
    return _sharedLocationController;
}

+ (void)startCurrentLocationHandling
{
    if (!_sharedLocationController)
        _sharedLocationController = [[DDLocationController alloc] init];
}

+ (void)updateCurrentLocation
{
    [_sharedLocationController forceSearchPlacemark];
}

+ (void)stopCurrentLocationHandling
{
    _sharedLocationController.delegate = nil;
    [_sharedLocationController release];
    _sharedLocationController = nil;
}

- (id)init
{
    if ((self = [super init]))
    {
        //create location manager
        locationManager_ = [[CLLocationManager alloc] init];
        locationManager_.delegate = self;
        locationManager_.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        if ([CLLocationManager locationServicesEnabled])
            [locationManager_ startUpdatingLocation];
        
        //save authorization status
        authorizationStatus_ = [CLLocationManager authorizationStatus];
        
        //api controller
        apiController_ = [[DDAPIController alloc] init];
        apiController_.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    //location manager
    [locationManager_ stopUpdatingLocation];
    locationManager_.delegate = nil;
    [locationManager_ release];
    
    //api controller
    apiController_.delegate = nil;
    [apiController_ release];
    
    [super dealloc];
}

- (void)forceSearchPlacemark
{
    [self forceSearchPlacemarkForLocation:locationManager_.location];
}

- (void)forceSearchPlacemarkForLocation:(CLLocation*)location
{
    [apiController_ cancelRequest:requestId_];
    requestId_ = [apiController_ getCurrentPlacemarkForLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    //unset error
    [errorLocation_ release];
    errorLocation_ = nil;
    
    //update location
    [location_ release];
    location_ = [newLocation retain];
    
    //check for geodecoding or first call
    if ([self.delegate locationManagerShouldGeoDecodeLocation:location_] || oldLocation == nil)
        [self forceSearchPlacemark];
    else
        [self.delegate locationManagerDidFoundLocation:location_];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    //save error
    [errorLocation_ release];
    errorLocation_ = [error retain];
    
    //update delegate
    [self.delegate locationManagerDidFailedWithError:error];
    
    //check if alert alredy shown
    static BOOL ownAlertOfDisabledServiceShown = NO;
    if (!ownAlertOfDisabledServiceShown)
    {
        //save flag
        ownAlertOfDisabledServiceShown = YES;
        
        //check if initially the status was not determined
        if (authorizationStatus_ == kCLAuthorizationStatusNotDetermined)
        {
            //check for current status
            if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)
            {
                //we don't handle the answer because:
                //1. we are not able to force dialog once again
                //2. we are not able to switch on location programatically
                //3. we are not able to open the settings
                //prompt the custom dialog
                [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:NSLocalizedString(@"This is very important feature in our app", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
            }
        }
    }
}

#pragma mark -
#pragma mark DDAPIControllerDelegate

- (void)getCurrentPlacemarkSucceed:(DDPlacemark *)placemark
{
    //unset error
    [errorPlacemark_ release];
    errorPlacemark_ = nil;
    
    //save placemark
    [placemark_ release];
    placemark_ = [placemark retain];
    
    //update delegate
    [self.delegate locationManagerDidFoundPlacemark:placemark];
}

- (void)getCurrentPlacemarkDidFailedWithError:(NSError *)error
{
    //save error
    [errorPlacemark_ release];
    errorPlacemark_ = [error retain];
    
    //update delegate
    [self.delegate locationManagerDidFailedWithError:error];
}

@end
