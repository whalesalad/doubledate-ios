//
//  DDDoubleDate.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDate.h"

@implementation DDDoubleDate

@synthesize identifier;
@synthesize status;
@synthesize title;
@synthesize details;
@synthesize dayPref;
@synthesize timePref;
@synthesize userId;
@synthesize wingId;
@synthesize updatedAt;
@synthesize locationId;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.identifier = [DDAPIObject numberForObject:[dictionary objectForKey:@"id"]];
        self.status = [DDAPIObject stringForObject:[dictionary objectForKey:@"status"]];
        self.title = [DDAPIObject stringForObject:[dictionary objectForKey:@"title"]];
        self.details = [DDAPIObject stringForObject:[dictionary objectForKey:@"details"]];
        self.dayPref = [DDAPIObject stringForObject:[dictionary objectForKey:@"day_pref"]];
        self.timePref = [DDAPIObject stringForObject:[dictionary objectForKey:@"time_pref"]];
        self.userId = [DDAPIObject numberForObject:[dictionary objectForKey:@"user_id"]];
        self.wingId = [DDAPIObject numberForObject:[dictionary objectForKey:@"wing_id"]];
        self.updatedAt = [DDAPIObject stringForObject:[dictionary objectForKey:@"updated_at"]];
        self.locationId = [DDAPIObject numberForObject:[dictionary objectForKey:@"location_id"]];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.identifier)
        [dictionary setObject:self.identifier forKey:@"id"];
    if (self.status)
        [dictionary setObject:self.status forKey:@"status"];
    if (self.title)
        [dictionary setObject:self.title forKey:@"title"];
    if (self.details)
        [dictionary setObject:self.details forKey:@"details"];
    if (self.dayPref)
        [dictionary setObject:self.dayPref forKey:@"day_pref"];
    if (self.timePref)
        [dictionary setObject:self.timePref forKey:@"time_pref"];
    if (self.userId)
        [dictionary setObject:self.userId forKey:@"user_id"];
    if (self.wingId)
        [dictionary setObject:self.wingId forKey:@"wing_id"];
    if (self.updatedAt)
        [dictionary setObject:self.updatedAt forKey:@"updated_at"];
    if (self.locationId)
        [dictionary setObject:self.locationId forKey:@"location_id"];
    return dictionary;
}

- (void)dealloc
{
    [identifier release];
    [status release];
    [title release];
    [details release];
    [dayPref release];
    [timePref release];
    [userId release];
    [wingId release];
    [updatedAt release];
    [locationId release];
    [super dealloc];
}

@end
