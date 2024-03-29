//
//  DDNotification.m
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDNotification.h"
#import "DDImage.h"
#import "DDDialog.h"

@implementation DDNotification

@synthesize identifier;
@synthesize uuid;
@synthesize notification;
@synthesize push;
@synthesize unread;
@synthesize callbackUrl;
@synthesize photo;
@synthesize createdAt;
@synthesize createdAtAgo;
@synthesize dialog;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.identifier = [DDAPIObject numberForObject:[dictionary objectForKey:@"id"]];
        self.uuid = [DDAPIObject stringForObject:[dictionary objectForKey:@"uuid"]];
        self.notification = [DDAPIObject stringForObject:[dictionary objectForKey:@"notification"]];
        self.push = [DDAPIObject numberForObject:[dictionary objectForKey:@"push"]];
        self.unread = [DDAPIObject numberForObject:[dictionary objectForKey:@"unread"]];
        self.callbackUrl = [DDAPIObject stringForObject:[dictionary objectForKey:@"callback_url"]];
        self.photo = [DDImage objectWithDictionary:[dictionary objectForKey:@"photo"]];
        self.createdAt = [DDAPIObject stringForObject:[dictionary objectForKey:@"created_at"]];
        self.createdAtAgo = [DDAPIObject stringForObject:[dictionary objectForKey:@"created_at_ago"]];
        if ([dictionary objectForKey:@"dialog"])
            self.dialog = [DDDialog objectWithDictionary:[dictionary objectForKey:@"dialog"]];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.identifier)
        [dictionary setObject:self.identifier forKey:@"id"];
    if (self.uuid)
        [dictionary setObject:self.uuid forKey:@"uuid"];
    if (self.notification)
        [dictionary setObject:self.notification forKey:@"notification"];
    if (self.push)
        [dictionary setObject:self.push forKey:@"push"];
    if (self.unread)
        [dictionary setObject:self.unread forKey:@"unread"];
    if (self.callbackUrl)
        [dictionary setObject:self.callbackUrl forKey:@"callback_url"];
    if (self.createdAt)
        [dictionary setObject:self.createdAt forKey:@"created_at"];
    if (self.createdAtAgo)
        [dictionary setObject:self.createdAtAgo forKey:@"created_at_ago"];
    return dictionary;
}

- (id)copyWithZone:(NSZone*)zone
{
    DDNotification *ret = [[[self class] allocWithZone:zone] initWithDictionary:[self dictionaryRepresentation]];
    ret.photo = [[self.photo copy] autorelease];
    ret.dialog = self.dialog;
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
    [uuid release];
    [notification release];
    [push release];
    [unread release];
    [callbackUrl release];
    [photo release];
    [createdAt release];
    [createdAtAgo release];
    [dialog release];
    [super dealloc];
}

@end
