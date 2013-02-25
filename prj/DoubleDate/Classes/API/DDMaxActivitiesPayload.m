//
//  DDMaxActivitiesPayload.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDMaxActivitiesPayload.h"

@implementation DDMaxActivitiesPayload

@synthesize activitiesCount;
@synthesize activitiesAllowed;
@synthesize unlockRequired;

@synthesize slug;
@synthesize cost;
@synthesize maxActivities;
@synthesize title;
@synthesize description;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.activitiesCount = [DDAPIObject numberForObject:[dictionary objectForKey:@"activities_count"]];
        self.activitiesAllowed = [DDAPIObject numberForObject:[dictionary objectForKey:@"activities_allowed"]];
        if ([[dictionary objectForKey:@"unlock_required"] isKindOfClass:[NSNumber class]])
        {
            self.unlockRequired = [dictionary objectForKey:@"unlock_required"];
        }
        else
        {
            dictionary = [dictionary objectForKey:@"unlock_required"];
            self.slug = [DDAPIObject stringForObject:[dictionary objectForKey:@"slug"]];
            self.cost = [DDAPIObject numberForObject:[dictionary objectForKey:@"cost"]];
            self.maxActivities = [DDAPIObject numberForObject:[dictionary objectForKey:@"max_activities"]];
            self.title = [DDAPIObject stringForObject:[dictionary objectForKey:@"title"]];
            self.description = [DDAPIObject stringForObject:[dictionary objectForKey:@"description"]];
        }
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.slug)
        [dictionary setObject:self.slug forKey:@"slug"];
    return dictionary;
}

- (id)copyWithZone:(NSZone*)zone
{
    DDMaxActivitiesPayload *ret = [[[self class] allocWithZone:zone] init];
    ret.activitiesCount = self.activitiesCount;
    ret.activitiesAllowed = self.activitiesAllowed;
    ret.unlockRequired = self.unlockRequired;
    ret.slug = self.slug;
    ret.cost = self.cost;
    ret.maxActivities = self.maxActivities;
    ret.title = self.title;
    ret.description = self.description;
    return ret;
}

- (void)dealloc
{
    [activitiesCount release];
    [activitiesAllowed release];
    [unlockRequired release];
    [slug release];
    [cost release];
    [maxActivities release];
    [title release];
    [description release];
    [super dealloc];
}

@end
