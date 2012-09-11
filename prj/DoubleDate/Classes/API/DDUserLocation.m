//
//  DDUserLocation.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDUserLocation.h"

@implementation DDUserLocation

@synthesize locationId;
@synthesize facebookId;
@synthesize name;
@synthesize latitude;
@synthesize longitude;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.locationId = [DDAPIObject stringForObject:[dictionary objectForKey:@"id"]];
        self.facebookId = [DDAPIObject stringForObject:[dictionary objectForKey:@"fb_id"]];
        self.name = [DDAPIObject stringForObject:[dictionary objectForKey:@"name"]];
        self.latitude = [DDAPIObject stringForObject:[dictionary objectForKey:@"lat"]];
        self.longitude = [DDAPIObject stringForObject:[dictionary objectForKey:@"lng"]];
    }
    return self;
}

- (void)dealloc
{
    [locationId release];
    [facebookId release];
    [name release];
    [latitude release];
    [longitude release];
    [super dealloc];
}

@end
