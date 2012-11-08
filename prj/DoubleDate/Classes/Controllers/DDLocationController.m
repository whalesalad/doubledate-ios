//
//  DDLocationController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDLocationController.h"

@interface DDLocationController ()<CLLocationManagerDelegate, DDAPIControllerDelegate>

@end

@implementation DDLocationController

@synthesize delegate;
@synthesize options;

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
        
        //set search options
        options = DDLocationSearchOptionsBoth;
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

- (void)forceSearchPlacemarks
{
    [self forceSearchPlacemarksForLocation:locationManager_.location];
}

- (void)forceSearchPlacemarksForLocation:(CLLocation*)location
{
    requestId_ = [apiController_ searchPlacemarksForLatitude:location.coordinate.latitude longitude:location.coordinate.longitude options:self.options];
}

- (CLLocation*)location
{
    return locationManager_.location;
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if ([self.delegate locationManagerShouldGeoDecodeLocation:newLocation])
    {
        if (![apiController_ isRequestExist:requestId_])
            [self forceSearchPlacemarks];
    }
    else
        [self.delegate locationManagerDidFoundLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [self.delegate locationManagerDidFailedWithError:error];
}

#pragma mark -
#pragma mark DDAPIControllerDelegate

- (void)searchPlacemarksSucceed:(NSArray*)placemarks
{
    [self.delegate locationManagerDidFoundPlacemarks:placemarks];
}

- (void)searchPlacemarksDidFailedWithError:(NSError*)error
{
    
}

@end
