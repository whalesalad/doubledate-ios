//
//  DDPlacemark.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDPlacemark.h"

@implementation DDPlacemark

@synthesize country;
@synthesize adminCode;
@synthesize adminName;
@synthesize latitude;
@synthesize name;
@synthesize identifier;
@synthesize facebookId;
@synthesize longitude;
@synthesize distance;
@synthesize locality;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.country = [DDAPIObject stringForObject:[dictionary objectForKey:@"country"]];
        self.adminCode = [DDAPIObject stringForObject:[dictionary objectForKey:@"admin_code"]];
        self.adminName = [DDAPIObject stringForObject:[dictionary objectForKey:@"admin_name"]];
        self.latitude = [DDAPIObject numberForObject:[dictionary objectForKey:@"latitude"]];
        self.name = [DDAPIObject stringForObject:[dictionary objectForKey:@"name"]];
        self.identifier = [DDAPIObject numberForObject:[dictionary objectForKey:@"id"]];
        self.facebookId = [DDAPIObject numberForObject:[dictionary objectForKey:@"facebook_id"]];
        self.longitude = [DDAPIObject numberForObject:[dictionary objectForKey:@"longitude"]];
        self.distance = [DDAPIObject stringForObject:[dictionary objectForKey:@"distance"]];
        self.locality = [DDAPIObject stringForObject:[dictionary objectForKey:@"locality"]];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.country)
        [dictionary setObject:self.country forKey:@"country"];
    if (self.adminCode)
        [dictionary setObject:self.adminCode forKey:@"admin_code"];
    if (self.adminName)
        [dictionary setObject:self.adminName forKey:@"admin_name"];
    if (self.latitude)
        [dictionary setObject:self.latitude forKey:@"latitude"];
    if (self.name)
        [dictionary setObject:self.name forKey:@"name"];
    if (self.identifier)
        [dictionary setObject:self.identifier forKey:@"id"];
    if (self.facebookId)
        [dictionary setObject:self.facebookId forKey:@"facebook_id"];
    if (self.longitude)
        [dictionary setObject:self.longitude forKey:@"longitude"];
    if (self.distance)
        [dictionary setObject:self.distance forKey:@"distance"];
    if (self.locality)
        [dictionary setObject:self.locality forKey:@"locality"];
    return dictionary;
}

- (void)dealloc
{
    [country release];
    [adminCode release];
    [adminName release];
    [latitude release];
    [name release];
    [identifier release];
    [facebookId release];
    [longitude release];
    [distance release];
    [locality release];
    [super dealloc];
}

@end
