//
//  DDEngagement.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDEngagement.h"
#import "DDShortUser.h"

NSString *DDEngagementStatusSent = @"sent";
NSString *DDEngagementStatusViewed = @"viewed";
NSString *DDEngagementStatusIgnored = @"ignored";
NSString *DDEngagementStatusAccepted = @"accepted";

@implementation DDEngagement

@synthesize identifier;
@synthesize userId;
@synthesize wingId;
@synthesize message;
@synthesize initialMessage;
@synthesize activityId;
@synthesize status;
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
        self.userId = [DDAPIObject numberForObject:[dictionary objectForKey:@"user_id"]];
        self.wingId = [DDAPIObject numberForObject:[dictionary objectForKey:@"wing_id"]];
        self.message = [DDAPIObject stringForObject:[dictionary objectForKey:@"message"]];
        self.initialMessage = [DDAPIObject stringForObject:[dictionary objectForKey:@"initial_message"]];
        self.activityId = [DDAPIObject numberForObject:[dictionary objectForKey:@"activity_id"]];
        self.status = [DDAPIObject stringForObject:[dictionary objectForKey:@"status"]];
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
    if (self.userId)
        [dictionary setObject:self.userId forKey:@"user_id"];
    if (self.wingId)
        [dictionary setObject:self.wingId forKey:@"wing_id"];
    if (self.message)
        [dictionary setObject:self.message forKey:@"message"];
    if (self.initialMessage)
        [dictionary setObject:self.initialMessage forKey:@"initial_message"];
    if (self.activityId)
        [dictionary setObject:self.activityId forKey:@"activity_id"];
    if (self.status)
        [dictionary setObject:self.status forKey:@"status"];
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

- (void)dealloc
{
    [identifier release];
    [userId release];
    [wingId release];
    [message release];
    [initialMessage release];
    [activityId release];
    [status release];
    [messagesCount release];
    [createdAt release];
    [createdAtAgo release];
    [user release];
    [wing release];
    [super dealloc];
}

@end
