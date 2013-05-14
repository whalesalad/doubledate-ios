//
//  DDPlacemark.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDPlacemark.h"

NSString *DDPlacemarkTypeCity = @"city";
NSString *DDPlacemarkTypeVenue = @"venue";

@implementation DDPlacemark

@synthesize activitiesCount;
@synthesize address;
@synthesize identifier;
@synthesize latitude;
@synthesize locality;
@synthesize longitude;
@synthesize name;
@synthesize state;
@synthesize usersCount;
@synthesize venue;
@synthesize country;
@synthesize type;
@synthesize locationName;
@synthesize iconRetina;
@synthesize icon;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.activitiesCount = [DDAPIObject numberForObject:[dictionary objectForKey:@"activities_count"]];
        self.address = [DDAPIObject stringForObject:[dictionary objectForKey:@"address"]];
        self.identifier = [DDAPIObject numberForObject:[dictionary objectForKey:@"id"]];
        self.latitude = [DDAPIObject numberForObject:[dictionary objectForKey:@"latitude"]];
        self.locality = [DDAPIObject stringForObject:[dictionary objectForKey:@"locality"]];
        self.longitude = [DDAPIObject numberForObject:[dictionary objectForKey:@"longitude"]];
        self.name = [DDAPIObject stringForObject:[dictionary objectForKey:@"name"]];
        self.state = [DDAPIObject stringForObject:[dictionary objectForKey:@"state"]];
        self.usersCount = [DDAPIObject numberForObject:[dictionary objectForKey:@"users_count"]];
        self.venue = [DDAPIObject stringForObject:[dictionary objectForKey:@"venue"]];
        self.country = [DDAPIObject stringForObject:[dictionary objectForKey:@"country"]];
        self.type = [DDAPIObject stringForObject:[dictionary objectForKey:@"type"]];
        self.locationName = [DDAPIObject stringForObject:[dictionary objectForKey:@"location_name"]];
        self.iconRetina = [DDAPIObject stringForObject:[dictionary objectForKey:@"icon_retina"]];
        self.icon = [DDAPIObject stringForObject:[dictionary objectForKey:@"icon"]];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.activitiesCount)
        [dictionary setObject:self.activitiesCount forKey:@"activities_count"];
    if (self.address)
        [dictionary setObject:self.address forKey:@"address"];
    if (self.identifier)
        [dictionary setObject:self.identifier forKey:@"id"];
    if (self.latitude)
        [dictionary setObject:self.latitude forKey:@"latitude"];
    if (self.locality)
        [dictionary setObject:self.locality forKey:@"locality"];
    if (self.longitude)
        [dictionary setObject:self.longitude forKey:@"longitude"];
    if (self.name)
        [dictionary setObject:self.name forKey:@"name"];
    if (self.state)
        [dictionary setObject:self.state forKey:@"state"];
    if (self.usersCount)
        [dictionary setObject:self.usersCount forKey:@"users_count"];
    if (self.venue)
        [dictionary setObject:self.venue forKey:@"venue"];
    if (self.country)
        [dictionary setObject:self.country forKey:@"country"];
    if (self.type)
        [dictionary setObject:self.type forKey:@"type"];
    if (self.locationName)
        [dictionary setObject:self.locationName forKey:@"location_name"];
    if (self.iconRetina)
        [dictionary setObject:self.iconRetina forKey:@"icon_retina"];
    if (self.icon)
        [dictionary setObject:self.icon forKey:@"icon"];
    return dictionary;
}

- (NSString*)uniqueKey
{
    return [NSString stringWithFormat:@"%d", [[self identifier] intValue]];
}

- (NSString*)uniqueKeyField
{
    return @"id";
}

- (BOOL)isVenue
{
    return [self.type isEqualToString:@"venue"];
}

- (BOOL)isCity
{
    return [self.type isEqualToString:@"city"];
}

- (void)dealloc
{
    [activitiesCount release];
    [address release];
    [identifier release];
    [latitude release];
    [locality release];
    [longitude release];
    [name release];
    [state release];
    [usersCount release];
    [venue release];
    [country release];
    [type release];
    [locationName release];
    [iconRetina release];
    [icon release];
    [super dealloc];
}

@end
