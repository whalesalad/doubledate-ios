//
//  DDDoubleDate.m
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDDoubleDate.h"
#import "DDShortUser.h"
#import "DDPlacemark.h"
#import "DDEngagement.h"

NSString *DDDoubleDateRelationshipOpen = @"open";
NSString *DDDoubleDateRelationshipOwner = @"owner";
NSString *DDDoubleDateRelationshipWing = @"wing";
NSString *DDDoubleDateRelationshipEngaged = @"engaged";

@implementation DDDoubleDate

@synthesize identifier;
@synthesize relationship;
@synthesize details;
@synthesize updatedAt;
@synthesize createdAt;
@synthesize myEngagementId;
@synthesize unreadCount;
@synthesize user;
@synthesize wing;
@synthesize location;
@synthesize engagement;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.identifier = [DDAPIObject numberForObject:[dictionary objectForKey:@"id"]];
        self.relationship = [DDAPIObject stringForObject:[dictionary objectForKey:@"relationship"]];
        self.details = [DDAPIObject stringForObject:[dictionary objectForKey:@"details"]];
        self.updatedAt = [DDAPIObject dateForObject:[dictionary objectForKey:@"updated_at"]];
        self.createdAt = [DDAPIObject dateForObject:[dictionary objectForKey:@"created_at"]];
        self.myEngagementId = [DDAPIObject numberForObject:[dictionary objectForKey:@"my_engagement_id"]];
        self.unreadCount = [DDAPIObject numberForObject:[dictionary objectForKey:@"unread_count"]];
        self.user = [DDShortUser objectWithDictionary:[dictionary objectForKey:@"user"]];
        if ([dictionary objectForKey:@"wing"])
            self.wing = [DDShortUser objectWithDictionary:[dictionary objectForKey:@"wing"]];
        else if ([dictionary objectForKey:@"ghost"])
            self.wing = [DDShortGhost objectWithDictionary:[dictionary objectForKey:@"ghost"]];
        self.location = [DDPlacemark objectWithDictionary:[dictionary objectForKey:@"location"]];
        if ([dictionary objectForKey:@"engagement"])
            self.engagement = [DDEngagement objectWithDictionary:[dictionary objectForKey:@"engagement"]];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.identifier)
        [dictionary setObject:self.identifier forKey:@"id"];
    if (self.relationship)
        [dictionary setObject:self.relationship forKey:@"relationship"];
    if (self.details)
        [dictionary setObject:self.details forKey:@"details"];
    if (self.updatedAt)
        [dictionary setObject:self.updatedAt forKey:@"updated_at"];
    if (self.createdAt)
        [dictionary setObject:self.createdAt forKey:@"created_at"];
    if (self.myEngagementId)
        [dictionary setObject:self.myEngagementId forKey:@"my_engagement_id"];
    if (self.unreadCount)
        [dictionary setObject:self.unreadCount forKey:@"unread_count"];
    if (self.user.identifier)
        [dictionary setObject:self.user.identifier forKey:@"user_id"];
    if (self.wing.facebookId)
        [dictionary setObject:self.wing.facebookId forKey:@"facebook_id"];
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
    ret.engagement = self.engagement;
    return ret;
}

- (NSString*)uniqueKey
{
    return [NSString stringWithFormat:@"%d", [[self identifier] intValue]];
}

- (NSString*)uniqueKeyField
{
    return @"id";
}

- (void)dealloc
{
    [identifier release];
    [relationship release];
    [details release];
    [updatedAt release];
    [createdAt release];
    [myEngagementId release];
    [unreadCount release];
    [user release];
    [wing release];
    [location release];
    [engagement release];
    [super dealloc];
}

@end
