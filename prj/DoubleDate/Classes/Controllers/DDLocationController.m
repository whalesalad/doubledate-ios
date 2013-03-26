//
//  DDLocationController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
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
        if ([CLLocationManager locationServicesEnabled])
            [locationManager_ startUpdatingLocation];
        
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
    
    //check for geodecoding
    if ([self.delegate locationManagerShouldGeoDecodeLocation:location_])
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
