//
//  DDImage.m
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDImage.h"

@implementation DDImage

@synthesize thumbUrl;
@synthesize smallUrl;
@synthesize mediumUrl;
@synthesize largeUrl;
@synthesize uploadImage;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.thumbUrl = [DDAPIObject stringForObject:[dictionary objectForKey:@"thumb"]];
        self.smallUrl = [DDAPIObject stringForObject:[dictionary objectForKey:@"small"]];
        self.mediumUrl = [DDAPIObject stringForObject:[dictionary objectForKey:@"medium"]];
        self.largeUrl = [DDAPIObject stringForObject:[dictionary objectForKey:@"large"]];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.thumbUrl)
        [dictionary setObject:self.thumbUrl forKey:@"thumb"];
    if (self.smallUrl)
        [dictionary setObject:self.smallUrl forKey:@"small"];
    if (self.mediumUrl)
        [dictionary setObject:self.mediumUrl forKey:@"medium"];
    if (self.largeUrl)
        [dictionary setObject:self.largeUrl forKey:@"large"];
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
    return self.thumbUrl;
}

- (NSString*)uniqueKeyField
{
    return @"thumb";
}

- (void)dealloc
{
    [thumbUrl release];
    [smallUrl release];
    [mediumUrl release];
    [largeUrl release];
    [uploadImage release];
    [super dealloc];
}

@end
