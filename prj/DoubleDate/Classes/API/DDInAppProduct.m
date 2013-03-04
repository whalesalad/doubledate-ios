//
//  DDInAppProduct.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDInAppProduct.h"

@implementation DDInAppProduct

@synthesize identifier;
@synthesize name;
@synthesize coins;
@synthesize popular;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.identifier = [DDAPIObject stringForObject:[dictionary objectForKey:@"identifier"]];
        self.name = [DDAPIObject stringForObject:[dictionary objectForKey:@"name"]];
        self.coins = [DDAPIObject numberForObject:[dictionary objectForKey:@"coins"]];
        self.popular = [DDAPIObject numberForObject:[dictionary objectForKey:@"popular"]];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.identifier)
        [dictionary setObject:self.identifier forKey:@"identifier"];
    if (self.name)
        [dictionary setObject:self.name forKey:@"name"];
    if (self.coins)
        [dictionary setObject:self.coins forKey:@"coins"];
    if (self.popular)
        [dictionary setObject:self.popular forKey:@"popular"];
    return dictionary;
}

- (NSString*)uniqueKey
{
    return [NSString stringWithFormat:@"%@", [self identifier]];
}

- (NSString*)uniqueKeyField
{
    return @"identifier";
}

- (void)dealloc
{
    [identifier release];
    [name release];
    [coins release];
    [popular release];
    [super dealloc];
}

@end
