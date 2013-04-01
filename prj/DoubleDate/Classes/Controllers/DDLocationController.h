//
//  DDLocationController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DDAPIController.h"

@protocol DDLocationControllerDelegate <NSObject>

- (void)locationManagerDidFoundLocation:(CLLocation*)location;
- (void)locationManagerDidFailedWithError:(NSError*)error;
- (BOOL)locationManagerShouldGeoDecodeLocation:(CLLocation*)location;
- (void)locationManagerDidFoundPlacemark:(DDPlacemark*)placemark;

@end

@interface DDLocationController : NSObject
{
    CLLocationManager *locationManager_;
    DDAPIController *apiController_;
    DDRequestId requestId_;
    CLLocation *location_;
    NSError *errorLocation_;
    DDPlacemark *placemark_;
    NSError *errorPlacemark_;
}

@property(nonatomic, assign) id<DDLocationControllerDelegate> delegate;

@property(nonatomic, readonly) CLLocation *lastLocation;
@property(nonatomic, readonly) NSError *errorLocation;

@property(nonatomic, readonly) DDPlacemark *lastPlacemark;
@property(nonatomic, readonly) NSError *errorPlacemark;

+ (DDLocationController*)currentLocationController;
+ (void)startCurrentLocationHandling;
+ (void)updateCurrentLocation;
+ (void)stopCurrentLocationHandling;

- (void)forceSearchPlacemark;
- (void)forceSearchPlacemarkForLocation:(CLLocation*)location;

@end
