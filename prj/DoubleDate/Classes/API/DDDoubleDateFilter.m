//
//  DDDoubleDateFilter.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDateFilter.h"
#import "DDPlacemark.h"

NSString *DDDoubleDateFilterHappeningWeekday = @"weekday";
NSString *DDDoubleDateFilterHappeningWeekend = @"weekend";

@implementation DDDoubleDateFilter

@synthesize happening;
@synthesize minAge;
@synthesize maxAge;
@synthesize query;
@synthesize location;

- (NSString*)queryString
{
    NSMutableString *ret = [NSMutableString string];
    if (self.happening)
        [ret appendFormat:@"%@happening=%@", [ret length]?@"&":@"", self.happening];
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

- (void)dealloc
{
    [happening release];
    [minAge release];
    [maxAge release];
    [query release];
    [location release];
    [super dealloc];
}

@end
