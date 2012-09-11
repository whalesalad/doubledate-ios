//
//  DDUser.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDUser.h"
#import "DDUserLocation.h"

@implementation DDUser

@synthesize birthday;
@synthesize lastName;
@synthesize userId;
@synthesize gender;
@synthesize age;
@synthesize photo;
@synthesize firstName;
@synthesize interestedIn;
@synthesize single;

@synthesize bio;

@synthesize interests;

@synthesize facebookId;

@synthesize email;
@synthesize password;

@synthesize location;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
            self.bio = [DDAPIObject stringForObject:[dictionary objectForKey:@"bio"]];
            self.birthday = [DDAPIObject stringForObject:[dictionary objectForKey:@"birthday"]];
            self.firstName = [DDAPIObject stringForObject:[dictionary objectForKey:@"first_name"]];
            self.gender = [DDAPIObject stringForObject:[dictionary objectForKey:@"gender"]];
            self.userId = [DDAPIObject stringForObject:[dictionary objectForKey:@"id"]];
            self.interestedIn = [DDAPIObject stringForObject:[dictionary objectForKey:@"interested_in"]];
            self.lastName = [DDAPIObject stringForObject:[dictionary objectForKey:@"last_name"]];
            self.single = [DDAPIObject stringForObject:[dictionary objectForKey:@"single"]];
            self.age = [DDAPIObject stringForObject:[dictionary objectForKey:@"age"]];
            self.photo = [DDAPIObject stringForObject:[dictionary objectForKey:@"photo"]];
            self.facebookId = [DDAPIObject stringForObject:[dictionary objectForKey:@"facebook_id"]];
            self.email = [DDAPIObject stringForObject:[dictionary objectForKey:@"email"]];
            self.password = [DDAPIObject stringForObject:[dictionary objectForKey:@"password"]];
            self.location = [[[DDUserLocation alloc] initWithDictionary:[DDAPIObject dictionaryForObject:[dictionary objectForKey:@"location"]]] autorelease];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.bio)
        [dictionary setObject:self.bio forKey:@"bio"];
    if (self.birthday)
        [dictionary setObject:self.birthday forKey:@"birthday"];
    if (self.firstName)
        [dictionary setObject:self.firstName forKey:@"first_name"];
    if (self.gender)
        [dictionary setObject:self.gender forKey:@"gender"];
    if (self.userId)
        [dictionary setObject:self.userId forKey:@"id"];
    if (self.interestedIn)
        [dictionary setObject:self.interestedIn forKey:@"interested_in"];
    if (self.lastName)
        [dictionary setObject:self.lastName forKey:@"last_name"];
    if (self.single)
        [dictionary setObject:self.single forKey:@"single"];
    if (self.age)
        [dictionary setObject:self.age forKey:@"age"];
    if (self.photo)
        [dictionary setObject:self.photo forKey:@"photo"];
    if (self.facebookId)
        [dictionary setObject:self.facebookId forKey:@"facebook_id"];
    if (self.email)
        [dictionary setObject:self.email forKey:@"email"];
    if (self.password)
        [dictionary setObject:self.password forKey:@"password"];
    if ([self.location dictionaryRepresentation])
        [dictionary setObject:[self.location dictionaryRepresentation] forKey:@"location"];
    return dictionary;
}

- (void)dealloc
{
    [birthday release];
    [lastName release];
    [userId release];
    [gender release];
    [age release];
    [photo release];
    [firstName release];
    [interestedIn release];
    [single release];
    [bio release];
    [interests release];
    [facebookId release];
    [email release];
    [password release];
    [location release];
    [super dealloc];
}

@end
