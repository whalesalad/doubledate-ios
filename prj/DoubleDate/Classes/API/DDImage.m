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

- (void)dealloc
{
    [downloadUrl release];
    [super dealloc];
}

@end
