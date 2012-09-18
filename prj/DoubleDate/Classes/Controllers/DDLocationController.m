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

- (void)forceSearchPlacemarks
{
    [apiController_ searchPlacemarksForLatitude:locationManager_.location.coordinate.latitude longitude:locationManager_.location.coordinate.longitude];
}

#pragma mark -
#pragma comment CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if ([self.delegate locationManagerShouldGeoDecodeLocation:newLocation])
        [self forceSearchPlacemarks];
    else
        [self.delegate locationManagerDidFoundLocation:newLocation];
}

#pragma mark -
#pragma comment DDAPIControllerDelegate

- (void)searchPlacemarksSucceed:(NSArray*)placemarks
{
    [self.delegate locationManagerDidFoundPlacemarks:placemarks];
}

- (void)searchPlacemarksDidFailedWithError:(NSError*)error
{
    
}

@end
