//
//  DDEngagement.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDEngagement.h"
#import "DDShortUser.h"

NSString *DDEngagementStatusLocked = @"locked";
NSString *DDEngagementStatusUnlocked = @"unlocked";
NSString *DDEngagementStatusExpired = @"expired";

@implementation DDEngagement

@synthesize identifier;
@synthesize activityId;
@synthesize activityTitle;
@synthesize activityUser;
@synthesize activityWing;
@synthesize userId;
@synthesize wingId;
@synthesize message;
@synthesize primaryMessage;
@synthesize status;
@synthesize unreadCount;
@synthesize createdAt;
@synthesize createdAtAgo;
@synthesize updatedAt;
@synthesize updatedAtAgo;
@synthesize timeRemaining;
@synthesize daysRemaining;
@synthesize user;
@synthesize wing;
@synthesize displayName;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.identifier = [DDAPIObject numberForObject:[dictionary objectForKey:@"id"]];
        self.activityId = [DDAPIObject numberForObject:[[dictionary objectForKey:@"activity"] objectForKey:@"id"]];
        self.activityTitle = [DDAPIObject stringForObject:[[dictionary objectForKey:@"activity"] objectForKey:@"title"]];
        self.activityUser = [DDShortUser objectWithDictionary:[[dictionary objectForKey:@"activity"] objectForKey:@"user"]];
        self.activityWing = [DDShortUser objectWithDictionary:[[dictionary objectForKey:@"activity"] objectForKey:@"wing"]];
        self.userId = [DDAPIObject numberForObject:[dictionary objectForKey:@"user_id"]];
        self.wingId = [DDAPIObject numberForObject:[dictionary objectForKey:@"wing_id"]];
        self.message = [DDAPIObject stringForObject:[dictionary objectForKey:@"message"]];
        self.primaryMessage = [DDAPIObject stringForObject:[dictionary objectForKey:@"primary_message"]];
        self.status = [DDAPIObject stringForObject:[dictionary objectForKey:@"status"]];
        self.unreadCount = [DDAPIObject numberForObject:[dictionary objectForKey:@"unread_count"]];
        self.createdAt = [DDAPIObject stringForObject:[dictionary objectForKey:@"created_at"]];
        self.createdAtAgo = [DDAPIObject stringForObject:[dictionary objectForKey:@"created_at_ago"]];
        self.updatedAt = [DDAPIObject stringForObject:[dictionary objectForKey:@"updated_at"]];
        self.updatedAtAgo = [DDAPIObject stringForObject:[dictionary objectForKey:@"updated_at_ago"]];
        self.timeRemaining = [DDAPIObject stringForObject:[dictionary objectForKey:@"time_remaining"]];
        self.daysRemaining = [DDAPIObject numberForObject:[dictionary objectForKey:@"days_remaining"]];
        self.user = [DDShortUser objectWithDictionary:[dictionary objectForKey:@"user"]];
        self.wing = [DDShortUser objectWithDictionary:[dictionary objectForKey:@"wing"]];
        self.displayName = [DDAPIObject stringForObject:[dictionary objectForKey:@"display_name"]];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.identifier)
        [dictionary setObject:self.identifier forKey:@"id"];
    if (self.activityId)
        [dictionary setObject:self.activityId forKey:@"activity_id"];
    if (self.activityTitle)
        [dictionary setObject:self.activityTitle forKey:@"activity_title"];
    if (self.userId)
        [dictionary setObject:self.userId forKey:@"user_id"];
    if (self.wingId)
        [dictionary setObject:self.wingId forKey:@"wing_id"];
    if (self.message)
        [dictionary setObject:self.message forKey:@"message"];
    if (self.primaryMessage)
        [dictionary setObject:self.primaryMessage forKey:@"primary_message"];
    if (self.status)
        [dictionary setObject:self.status forKey:@"status"];
    if (self.unreadCount)
        [dictionary setObject:self.unreadCount forKey:@"unread_count"];
    if (self.createdAt)
        [dictionary setObject:self.createdAt forKey:@"created_at"];
    if (self.createdAtAgo)
        [dictionary setObject:self.createdAtAgo forKey:@"created_at_ago"];
    if (self.timeRemaining)
        [dictionary setObject:self.timeRemaining forKey:@"time_remaining"];
    if (self.daysRemaining)
        [dictionary setObject:self.daysRemaining forKey:@"days_remaining"];
    if (self.displayName)
        [dictionary setObject:self.displayName forKey:@"display_name"];
    return dictionary;
}

- (id)copyWithZone:(NSZone*)zone
{
    DDEngagement *ret = [[[self class] allocWithZone:zone] initWithDictionary:[self dictionaryRepresentation]];
    ret.user = self.user;
    ret.wing = self.wing;
    ret.activityId = self.activityId;
    ret.activityTitle = self.activityTitle;
    ret.activityUser = self.activityUser;
    ret.activityWing = self.activityWing;
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
    [activityId release];
    [activityTitle release];
    [activityUser release];
    [activityWing release];
    [userId release];
    [wingId release];
    [message release];
    [primaryMessage release];
    [status release];
    [unreadCount release];
    [createdAt release];
    [createdAtAgo release];
    [timeRemaining release];
    [daysRemaining release];
    [user release];
    [wing release];
    [displayName release];
    [super dealloc];
}

@end
