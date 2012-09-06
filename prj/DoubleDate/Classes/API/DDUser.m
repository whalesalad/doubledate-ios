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
@synthesize bio;
@synthesize lastName;
@synthesize userId;
@synthesize facebookId;
@synthesize gender;
@synthesize email;
@synthesize age;
@synthesize photo;
@synthesize firstName;
@synthesize interestedIn;
@synthesize single;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
            self.bio = [DDAPIObject stringForObject:[dictionary objectForKey:@"bio"]];
            self.birthday = [DDAPIObject stringForObject:[dictionary objectForKey:@"birthday"]];
            self.email = [DDAPIObject stringForObject:[dictionary objectForKey:@"email"]];
            self.facebookId = [DDAPIObject stringForObject:[dictionary objectForKey:@"facebook_id"]];
            self.firstName = [DDAPIObject stringForObject:[dictionary objectForKey:@"first_name"]];
            self.gender = [DDAPIObject stringForObject:[dictionary objectForKey:@"gender"]];
            self.userId = [DDAPIObject stringForObject:[dictionary objectForKey:@"id"]];
            self.interestedIn = [DDAPIObject stringForObject:[dictionary objectForKey:@"interested_in"]];
            self.lastName = [DDAPIObject stringForObject:[dictionary objectForKey:@"last_name"]];
            self.single = [DDAPIObject stringForObject:[dictionary objectForKey:@"single"]];
            self.age = [DDAPIObject stringForObject:[dictionary objectForKey:@"age"]];
            self.photo = [DDAPIObject stringForObject:[dictionary objectForKey:@"photo"]];
    }
    return self;
}

- (void)dealloc
{
    [birthday release];
    [bio release];
    [lastName release];
    [userId release];
    [facebookId release];
    [gender release];
    [email release];
    [age release];
    [photo release];
    [firstName release];
    [interestedIn release];
    [single release];
    [super dealloc];
}

@end
