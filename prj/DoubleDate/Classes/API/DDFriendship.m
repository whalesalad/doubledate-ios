//
//  DDFriendship.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 08.10.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDFriendship.h"

@implementation DDFriendship

@synthesize approved;
@synthesize createdAt;
@synthesize identifier;
@synthesize uuid;
@synthesize meUser;
@synthesize friendUser;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.approved = [DDAPIObject numberForObject:[dictionary objectForKey:@"approved"]];
        self.createdAt = [DDAPIObject stringForObject:[dictionary objectForKey:@"created_at"]];
        self.identifier = [DDAPIObject numberForObject:[dictionary objectForKey:@"id"]];
        self.uuid = [DDAPIObject stringForObject:[dictionary objectForKey:@"uuid"]];
        self.meUser = [DDShortUser objectWithDictionary:[dictionary objectForKey:@"user"]];
        self.friendUser = [DDShortUser objectWithDictionary:[dictionary objectForKey:@"friend"]];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.approved)
        [dictionary setObject:self.approved forKey:@"approved"];
    if (self.createdAt)
        [dictionary setObject:self.createdAt forKey:@"created_at"];
    if (self.identifier)
        [dictionary setObject:self.identifier forKey:@"id"];
    if (self.uuid)
        [dictionary setObject:self.uuid forKey:@"uuid"];
    if (self.meUser)
        [dictionary setObject:[self.meUser dictionaryRepresentation] forKey:@"user"];
    if (self.friendUser)
        [dictionary setObject:[self.friendUser dictionaryRepresentation] forKey:@"friend"];
    return dictionary;
}

- (void)dealloc
{
    [approved release];
    [createdAt release];
    [identifier release];
    [uuid release];
    [meUser release];
    [friendUser release];
    [super dealloc];
}

@end
