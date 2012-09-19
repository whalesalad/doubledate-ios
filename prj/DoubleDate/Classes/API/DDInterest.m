//
//  DDInterest.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDInterest.h"

@implementation DDInterest

@synthesize identifier;
@synthesize name;
@synthesize facebookId;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
            self.identifier = [DDAPIObject numberForObject:[dictionary objectForKey:@"id"]];
            self.name = [DDAPIObject stringForObject:[dictionary objectForKey:@"name"]];
            self.facebookId = [DDAPIObject numberForObject:[dictionary objectForKey:@"facebook_id"]];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.identifier)
        [dictionary setObject:self.identifier forKey:@"id"];
    if (self.name)
        [dictionary setObject:self.name forKey:@"name"];
    if (self.facebookId)
        [dictionary setObject:self.facebookId forKey:@"facebook_id"];
    return dictionary;
}

- (void)dealloc
{
    [identifier release];
    [name release];
    [facebookId release];
    [super dealloc];
}

@end