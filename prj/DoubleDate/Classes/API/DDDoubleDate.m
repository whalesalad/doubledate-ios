//
//  DDDoubleDate.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDate.h"
#import "DDShortUser.h"
#import "DDPlacemark.h"

NSString *DDDoubleDateDayPrefWeekday = @"weekday";
NSString *DDDoubleDateDayPrefWeekend = @"weekend";
NSString *DDDoubleDateTimePrefDaytime = @"day";
NSString *DDDoubleDateTimePrefNighttime = @"night";

@implementation DDDoubleDate

@synthesize identifier;
@synthesize status;
@synthesize title;
@synthesize details;
@synthesize dayPref;
@synthesize timePref;
@synthesize updatedAt;
@synthesize user;
@synthesize wing;
@synthesize location;

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
        self.updatedAt = [DDAPIObject stringForObject:[dictionary objectForKey:@"updated_at"]];
        self.user = [DDShortUser objectWithDictionary:[dictionary objectForKey:@"user"]];
        self.wing = [DDShortUser objectWithDictionary:[dictionary objectForKey:@"wing"]];
        self.location = [DDPlacemark objectWithDictionary:[dictionary objectForKey:@"location"]];
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
    if (self.updatedAt)
        [dictionary setObject:self.updatedAt forKey:@"updated_at"];
    if (self.user.identifier)
        [dictionary setObject:self.user.identifier forKey:@"user_id"];
    if (self.wing.identifier)
        [dictionary setObject:self.wing.identifier forKey:@"wing_id"];
    if (self.location.identifier)
        [dictionary setObject:self.location.identifier forKey:@"location_id"];
    return dictionary;
}

- (id)copyWithZone:(NSZone*)zone
{
    DDDoubleDate *ret = [[[self class] allocWithZone:zone] initWithDictionary:[self dictionaryRepresentation]];
    ret.user = self.user;
    ret.wing = self.wing;
    ret.location = self.location;
    return ret;
}

- (void)dealloc
{
    [identifier release];
    [status release];
    [title release];
    [details release];
    [dayPref release];
    [timePref release];
    [updatedAt release];
    [user release];
    [wing release];
    [location release];
    [super dealloc];
}

@end
