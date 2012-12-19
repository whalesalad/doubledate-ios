//
//  DDMessage.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDMessage.h"

@implementation DDMessage

@synthesize createdAt;
@synthesize identifier;
@synthesize message;
@synthesize userId;
@synthesize firstName;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.createdAt = [DDAPIObject stringForObject:[dictionary objectForKey:@"created_at"]];
        self.identifier = [DDAPIObject numberForObject:[dictionary objectForKey:@"id"]];
        self.message = [DDAPIObject stringForObject:[dictionary objectForKey:@"message"]];
        self.userId = [DDAPIObject numberForObject:[dictionary objectForKey:@"user_id"]];
        self.firstName = [DDAPIObject stringForObject:[dictionary objectForKey:@"first_name"]];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.createdAt)
        [dictionary setObject:self.createdAt forKey:@"created_at"];
    if (self.identifier)
        [dictionary setObject:self.identifier forKey:@"id"];
    if (self.message)
        [dictionary setObject:self.message forKey:@"message"];
    if (self.userId)
        [dictionary setObject:self.userId forKey:@"user_id"];
    if (self.firstName)
        [dictionary setObject:self.firstName forKey:@"first_name"];
    return dictionary;
}

- (void)dealloc
{
    [createdAt release];
    [identifier release];
    [message release];
    [userId release];
    [firstName release];
    [super dealloc];
}

@end
