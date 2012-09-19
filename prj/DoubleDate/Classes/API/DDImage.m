//
//  DDImage.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDImage.h"

@implementation DDImage

@synthesize downloadUrl;
@synthesize uploadImage;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
            self.downloadUrl = [DDAPIObject stringForObject:[dictionary objectForKey:@"thumb"]];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.downloadUrl)
        [dictionary setObject:self.downloadUrl forKey:@"thumb"];
    return dictionary;
}

- (id)copyWithZone:(NSZone*)zone
{
    DDImage *ret = [[[self class] allocWithZone:zone] initWithDictionary:[self dictionaryRepresentation]];
    ret.uploadImage = self.uploadImage;
    return ret;
}

- (void)dealloc
{
    [downloadUrl release];
    [uploadImage release];
    [super dealloc];
}

@end
