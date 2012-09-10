//
//  DDUser.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDUser.h"

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
    }
    return self;
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
    [super dealloc];
}

@end
