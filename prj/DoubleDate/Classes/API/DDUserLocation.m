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

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.locationId)
        [dictionary setObject:self.locationId forKey:@"id"];
    if (self.facebookId)
        [dictionary setObject:self.facebookId forKey:@"fb_id"];
    if (self.name)
        [dictionary setObject:self.name forKey:@"name"];
    if (self.latitude)
        [dictionary setObject:self.latitude forKey:@"lat"];
    if (self.longitude)
        [dictionary setObject:self.longitude forKey:@"lng"];
    return dictionary;
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
