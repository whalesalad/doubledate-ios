//
//  DDImage.m
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDImage.h"

@implementation DDImage

@synthesize identifier;
@synthesize thumbUrl;
@synthesize smallUrl;
@synthesize mediumUrl;
@synthesize largeUrl;
@synthesize originalUrl;
@synthesize facebookPhoto;
@synthesize uploadImage;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.identifier = [DDAPIObject stringForObject:[dictionary objectForKey:@"id"]];
        self.thumbUrl = [DDAPIObject stringForObject:[dictionary objectForKey:@"thumb"]];
        self.smallUrl = [DDAPIObject stringForObject:[dictionary objectForKey:@"small"]];
        self.mediumUrl = [DDAPIObject stringForObject:[dictionary objectForKey:@"medium"]];
        self.largeUrl = [DDAPIObject stringForObject:[dictionary objectForKey:@"large"]];
        self.originalUrl = [DDAPIObject stringForObject:[dictionary objectForKey:@"original"]];
        self.facebookPhoto = [DDAPIObject numberForObject:[dictionary objectForKey:@"facebook_photo"]];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.identifier)
        [dictionary setObject:self.identifier forKey:@"id"];
    if (self.thumbUrl)
        [dictionary setObject:self.thumbUrl forKey:@"thumb"];
    if (self.smallUrl)
        [dictionary setObject:self.smallUrl forKey:@"small"];
    if (self.mediumUrl)
        [dictionary setObject:self.mediumUrl forKey:@"medium"];
    if (self.largeUrl)
        [dictionary setObject:self.largeUrl forKey:@"large"];
    if (self.originalUrl)
        [dictionary setObject:self.originalUrl forKey:@"original"];
    if (self.facebookPhoto)
        [dictionary setObject:self.facebookPhoto forKey:@"facebook_photo"];
    return dictionary;
}

- (id)copyWithZone:(NSZone*)zone
{
    DDImage *ret = [[[self class] allocWithZone:zone] initWithDictionary:[self dictionaryRepresentation]];
    ret.uploadImage = self.uploadImage;
    return ret;
}

- (NSString*)uniqueKey
{
    return self.identifier;
}

- (NSString*)uniqueKeyField
{
    return @"id";
}

- (void)dealloc
{
    [identifier release];
    [thumbUrl release];
    [smallUrl release];
    [mediumUrl release];
    [largeUrl release];
    [originalUrl release];
    [facebookPhoto release];
    [uploadImage release];
    [super dealloc];
}

@end
