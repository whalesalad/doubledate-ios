//
//  DDLocationController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DDAPIController.h"

@protocol DDLocationControllerDelegate <NSObject>

- (void)locationManagerDidFoundLocation:(CLLocation*)location;
- (BOOL)locationManagerShouldGeoDecodeLocation:(CLLocation*)location;
- (void)locationManagerDidFoundPlacemarks:(NSArray*)placemarks;

@end

@interface DDLocationController : NSObject
{
    CLLocationManager *locationManager_;
    DDAPIController *apiController_;
}

@property(nonatomic, assign) id<DDLocationControllerDelegate> delegate;

- (void)forceSearchPlacemarks;

@end