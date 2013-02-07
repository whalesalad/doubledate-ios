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

@implementation DDEngagement

@synthesize identifier;
@synthesize activityId;
@synthesize userId;
@synthesize wingId;
@synthesize message;
@synthesize primaryMessage;
@synthesize status;
@synthesize unreadCount;
@synthesize messagesCount;
@synthesize createdAt;
@synthesize createdAtAgo;
@synthesize user;
@synthesize wing;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.identifier = [DDAPIObject numberForObject:[dictionary objectForKey:@"id"]];
        self.activityId = [DDAPIObject numberForObject:[dictionary objectForKey:@"activity_id"]];
        self.userId = [DDAPIObject numberForObject:[dictionary objectForKey:@"user_id"]];
        self.wingId = [DDAPIObject numberForObject:[dictionary objectForKey:@"wing_id"]];
        self.message = [DDAPIObject stringForObject:[dictionary objectForKey:@"message"]];
        self.primaryMessage = [DDAPIObject stringForObject:[dictionary objectForKey:@"primary_message"]];
        self.status = [DDAPIObject stringForObject:[dictionary objectForKey:@"status"]];
        self.unreadCount = [DDAPIObject numberForObject:[dictionary objectForKey:@"unread_count"]];
        self.messagesCount = [DDAPIObject numberForObject:[dictionary objectForKey:@"messages_count"]];
        self.createdAt = [DDAPIObject stringForObject:[dictionary objectForKey:@"created_at"]];
        self.createdAtAgo = [DDAPIObject stringForObject:[dictionary objectForKey:@"created_at_ago"]];
        self.user = [DDShortUser objectWithDictionary:[dictionary objectForKey:@"user"]];
        self.wing = [DDShortUser objectWithDictionary:[dictionary objectForKey:@"wing"]];
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
    if (self.messagesCount)
        [dictionary setObject:self.messagesCount forKey:@"messages_count"];
    if (self.createdAt)
        [dictionary setObject:self.createdAt forKey:@"created_at"];
    if (self.createdAtAgo)
        [dictionary setObject:self.createdAtAgo forKey:@"created_at_ago"];
    return dictionary;
}

- (id)copyWithZone:(NSZone*)zone
{
    DDEngagement *ret = [[[self class] allocWithZone:zone] initWithDictionary:[self dictionaryRepresentation]];
    ret.user = self.user;
    ret.wing = self.wing;
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
    [userId release];
    [wingId release];
    [message release];
    [primaryMessage release];
    [status release];
    [unreadCount release];
    [messagesCount release];
    [createdAt release];
    [createdAtAgo release];
    [user release];
    [wing release];
    [super dealloc];
}

@end
