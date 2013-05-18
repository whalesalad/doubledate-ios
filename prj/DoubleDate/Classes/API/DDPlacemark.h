//
//  DDPlacemark.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "CoreLocation/CoreLocation.h"
#import "DDAPIObject.h"

extern NSString *DDPlacemarkTypeCity;
extern NSString *DDPlacemarkTypeVenue;

@interface DDPlacemark : DDAPIObject

@property(nonatomic, retain) NSNumber *identifier;
@property(nonatomic, retain) NSString *type;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSNumber *latitude;
@property(nonatomic, retain) NSNumber *longitude;
@property(nonatomic, retain) NSString *locality;
@property(nonatomic, retain) NSString *state;
@property(nonatomic, retain) NSString *country;

@property(nonatomic, retain) NSString *locationName;
@property(nonatomic, retain) NSString *venue;
@property(nonatomic, retain) NSString *iconRetina;
@property(nonatomic, retain) NSString *icon;
@property(nonatomic, retain) NSNumber *distance;
@property(nonatomic, retain) NSString *address;

- (BOOL)isVenue;
- (BOOL)isCity;
- (CLLocationCoordinate2D)coordinate;

//- (BOOL)locationManagerShouldGeoDecodeLocation:(CLLocation*)location;

@end


