//
//  DDDoubleDateFilter.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDateFilter.h"

NSString *DDDoubleDateFilterSortClosest = @"closest";
NSString *DDDoubleDateFilterSortNewest = @"newest";
NSString *DDDoubleDateFilterSortOldest = @"oldest";
NSString *DDDoubleDateFilterHappeningWeekday = @"weekday";
NSString *DDDoubleDateFilterHappeningWeekend = @"weekend";

@implementation DDDoubleDateFilter

@synthesize sort;
@synthesize happening;
@synthesize minAge;
@synthesize maxAge;
@synthesize query;
@synthesize distance;
@synthesize latitude;
@synthesize longitude;

- (NSString*)queryString
{
    NSMutableString *ret = [NSMutableString string];
    if (self.sort)
        [ret appendFormat:@"%@sort=%@", [ret length]?@"&":@"", self.sort];
    if (self.happening)
        [ret appendFormat:@"%@happening=%@", [ret length]?@"&":@"", self.happening];
    if (self.minAge)
        [ret appendFormat:@"%@min_age=%d", [ret length]?@"&":@"", [self.minAge intValue]];
    if (self.maxAge)
        [ret appendFormat:@"%@max_age=%d", [ret length]?@"&":@"", [self.maxAge intValue]];
    if (self.query)
        [ret appendFormat:@"%@query=%@", [ret length]?@"&":@"", self.query];
    if (self.distance)
        [ret appendFormat:@"%@distance=%@", [ret length]?@"&":@"", self.distance];
    if (self.latitude)
        [ret appendFormat:@"%@latitude=%f", [ret length]?@"&":@"", [self.latitude floatValue]];
    if (self.longitude)
        [ret appendFormat:@"%@longitude=%f", [ret length]?@"&":@"", [self.longitude floatValue]];
    return ret;
}

- (void)dealloc
{
    [sort release];
    [happening release];
    [minAge release];
    [maxAge release];
    [query release];
    [distance release];
    [latitude release];
    [longitude release];
    [super dealloc];
}

@end
