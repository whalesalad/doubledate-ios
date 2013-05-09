//
//  DDDoubleDateFilter.m
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDDoubleDateFilter.h"
#import "DDPlacemark.h"

@implementation DDDoubleDateFilter

@synthesize minAge;
@synthesize maxAge;
@synthesize query;
@synthesize location;

- (NSString*)queryString
{
    NSMutableString *ret = [NSMutableString string];
    if (self.minAge)
        [ret appendFormat:@"%@min_age=%d", [ret length]?@"&":@"", [self.minAge intValue]];
    if (self.maxAge)
        [ret appendFormat:@"%@max_age=%d", [ret length]?@"&":@"", [self.maxAge intValue]];
    if (self.query)
        [ret appendFormat:@"%@query=%@", [ret length]?@"&":@"", self.query];
    if (self.location)
    {
        [ret appendFormat:@"%@latitude=%f", [ret length]?@"&":@"", [self.location.latitude floatValue]];
        [ret appendFormat:@"%@longitude=%f", [ret length]?@"&":@"", [self.location.longitude floatValue]];
    }
    return ret;
}

- (id)copyWithZone:(NSZone*)zone
{
    DDDoubleDateFilter *ret = [[[self class] allocWithZone:zone] init];
    ret.minAge = self.minAge;
    ret.maxAge = self.maxAge;
    ret.query = self.query;
    ret.location = self.location;
    return ret;
}

- (void)dealloc
{
    [minAge release];
    [maxAge release];
    [query release];
    [location release];
    [super dealloc];
}

@end
