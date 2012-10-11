//
//  DDShortUser.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 09.10.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDShortUser.h"

@implementation DDShortUser

@synthesize gender;
@synthesize identifier;
@synthesize facebookId;
@synthesize fullName;
@synthesize name;
@synthesize age;
@synthesize location;
@synthesize photo;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.gender = [DDAPIObject stringForObject:[dictionary objectForKey:@"gender"]];
        self.identifier = [DDAPIObject numberForObject:[dictionary objectForKey:@"id"]];
        self.facebookId = [DDAPIObject stringForObject:[dictionary objectForKey:@"facebook_id"]];
        self.fullName = [DDAPIObject stringForObject:[dictionary objectForKey:@"full_name"]];
        self.name = [DDAPIObject stringForObject:[dictionary objectForKey:@"name"]];
        self.age = [DDAPIObject numberForObject:[dictionary objectForKey:@"age"]];
        self.location = [DDAPIObject stringForObject:[dictionary objectForKey:@"location"]];
        self.photo = [DDImage objectWithDictionary:[dictionary objectForKey:@"photo"]];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.gender)
        [dictionary setObject:self.gender forKey:@"gender"];
    if (self.identifier)
        [dictionary setObject:self.identifier forKey:@"id"];
    if (self.facebookId)
        [dictionary setObject:self.facebookId forKey:@"facebook_id"];
    if (self.fullName)
        [dictionary setObject:self.fullName forKey:@"full_name"];
    if (self.name)
        [dictionary setObject:self.name forKey:@"name"];
    if (self.age)
        [dictionary setObject:self.age forKey:@"age"];
    if (self.location)
        [dictionary setObject:self.location forKey:@"location"];
    if (self.photo)
        [dictionary setObject:[self.photo dictionaryRepresentation] forKey:@"photo"];
    return dictionary;
}

- (void)dealloc
{
    [gender release];
    [identifier release];
    [facebookId release];
    [fullName release];
    [name release];
    [age release];
    [location release];
    [photo release];
    [super dealloc];
}

@end
