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
@synthesize squareUrl;
@synthesize facebookPhoto;
@synthesize uploadImage;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.identifier = [DDAPIObject stringForObject:[dictionary objectForKey:@"id"]];
        self.thumbUrl = [DDAPIObject stringForObject:[dictionary objectForKey:@"thumb"]];
        self.squareUrl = [DDAPIObject stringForObject:[dictionary objectForKey:@"square"]];
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
    if (self.squareUrl)
        [dictionary setObject:self.squareUrl forKey:@"square"];
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
    [squareUrl release];
    [facebookPhoto release];
    [uploadImage release];
    [super dealloc];
}

@end
