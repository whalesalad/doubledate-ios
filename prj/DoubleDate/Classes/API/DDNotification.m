//
//  DDNotification.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDNotification.h"
#import "DDImage.h"

@implementation DDNotification

@synthesize identifier;
@synthesize uuid;
@synthesize notification;
@synthesize push;
@synthesize unread;
@synthesize callbackUrl;
@synthesize photos;
@synthesize createdAt;
@synthesize createdAtAgo;

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
        NSArray *photosDicArray = [DDAPIObject arrayForObject:[dictionary objectForKey:@"photos"]];
        NSMutableArray *photosObjArray = [NSMutableArray array];
        for (NSDictionary *photoDic in photosDicArray)
        {
            DDImage *photo = [DDImage objectWithDictionary:photoDic];
            [photosObjArray addObject:photo];
        }
        if ([photosObjArray count])
            self.photos = [NSArray arrayWithArray:photosObjArray];
        self.createdAt = [DDAPIObject stringForObject:[dictionary objectForKey:@"created_at"]];
        self.createdAtAgo = [DDAPIObject stringForObject:[dictionary objectForKey:@"created_at_ago"]];
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
    ret.photos = self.photos;
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
    [photos release];
    [createdAt release];
    [createdAtAgo release];
    [super dealloc];
}

@end
