//
//  DDUser.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDUser.h"
#import "DDLocation.h"
#import "DDImage.h"
#import "DDInterest.h"

NSString *DDUserGenderMale = @"male";
NSString *DDUserGenderFemale = @"female";
NSString *DDUserInterestGuys = @"guys";
NSString *DDUserInterestGirls = @"girls";
NSString *DDUserInterestBoth = @"both";

@implementation DDUser

@synthesize birthday;
@synthesize lastName;
@synthesize userId;
@synthesize gender;
@synthesize age;
@synthesize firstName;
@synthesize interestedIn;
@synthesize single;

@synthesize bio;

@synthesize facebookId;
@synthesize facebookAccessToken;

@synthesize email;
@synthesize password;

@synthesize location;

@synthesize photo;

@synthesize interests;

@synthesize uuid;

@synthesize inviteSlug;
@synthesize invitePath;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.bio = [DDAPIObject stringForObject:[dictionary objectForKey:@"bio"]];
        self.birthday = [DDAPIObject stringForObject:[dictionary objectForKey:@"birthday"]];
        self.firstName = [DDAPIObject stringForObject:[dictionary objectForKey:@"first_name"]];
        self.gender = [DDAPIObject stringForObject:[dictionary objectForKey:@"gender"]];
        self.userId = [DDAPIObject numberForObject:[dictionary objectForKey:@"id"]];
        self.interestedIn = [DDAPIObject stringForObject:[dictionary objectForKey:@"interested_in"]];
        self.lastName = [DDAPIObject stringForObject:[dictionary objectForKey:@"last_name"]];
        self.single = [DDAPIObject numberForObject:[dictionary objectForKey:@"single"]];
        self.age = [DDAPIObject numberForObject:[dictionary objectForKey:@"age"]];
        self.facebookId = [DDAPIObject numberForObject:[dictionary objectForKey:@"facebook_id"]];
        self.facebookAccessToken = [DDAPIObject stringForObject:[dictionary objectForKey:@"facebook_access_token"]];
        self.email = [DDAPIObject stringForObject:[dictionary objectForKey:@"email"]];
        self.password = [DDAPIObject stringForObject:[dictionary objectForKey:@"password"]];
        self.location = [DDLocation objectWithDictionary:[dictionary objectForKey:@"location"]];
        self.photo = [DDImage objectWithDictionary:[dictionary objectForKey:@"photo"]];
        NSArray *interestsDicArray = [DDAPIObject arrayForObject:[dictionary objectForKey:@"interests"]];
        NSMutableArray *interestsObjArray = [NSMutableArray array];
        for (NSDictionary *interestDic in interestsDicArray)
        {
            DDInterest *interest = [DDInterest objectWithDictionary:interestDic];
            [interestsObjArray addObject:interest];
        }
        if ([interestsObjArray count])
            self.interests = [NSArray arrayWithArray:interestsObjArray];
        self.uuid = [DDAPIObject stringForObject:[dictionary objectForKey:@"uuid"]];
        self.inviteSlug = [DDAPIObject stringForObject:[dictionary objectForKey:@"invite_slug"]];
        self.invitePath = [DDAPIObject stringForObject:[dictionary objectForKey:@"invite_path"]];
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
    if (self.facebookAccessToken)
        [dictionary setObject:self.facebookAccessToken forKey:@"facebook_access_token"];
    if (self.email)
        [dictionary setObject:self.email forKey:@"email"];
    if (self.password)
        [dictionary setObject:self.password forKey:@"password"];
    if (self.location.identifier)
        [dictionary setObject:self.location.identifier forKey:@"location_id"];
    if ([self.photo dictionaryRepresentation])
        [dictionary setObject:[self.photo dictionaryRepresentation] forKey:@"photo"];
    if ([self.interests count])
    {
        NSMutableArray *interestsDicArray = [NSMutableArray array];
        for (DDInterest *interest in self.interests)
            [interestsDicArray addObject:interest.name];
        [dictionary setObject:interestsDicArray forKey:@"interest_names"];
    }
    if (self.uuid)
        [dictionary setObject:self.uuid forKey:@"uuid"];
    if (self.inviteSlug)
        [dictionary setObject:self.inviteSlug forKey:@"invite_slug"];
    if (self.invitePath)
        [dictionary setObject:self.invitePath forKey:@"invite_path"];
    return dictionary;
}

- (id)copyWithZone:(NSZone*)zone
{
    DDUser *ret = [[[self class] allocWithZone:zone] initWithDictionary:[self dictionaryRepresentation]];
    ret.photo = [[self.photo copy] autorelease];
    ret.location = [[self.location copy] autorelease];
    ret.interests = self.interests;
    return ret;
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
    [facebookId release];
    [facebookAccessToken release];
    [email release];
    [password release];
    [location release];
    [interests release];
    [uuid release];
    [inviteSlug release];
    [invitePath release];
    [super dealloc];
}

@end
