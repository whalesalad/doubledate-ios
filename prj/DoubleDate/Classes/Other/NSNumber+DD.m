//
//  NSNumber+DD.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "NSNumber+DD.h"

@implementation NSNumber (DD)

- (NSString*)readableNumber
{
    CGFloat floatValue = [self floatValue];
    if (floatValue > 1000000)
        return [NSString stringWithFormat:@"%.02fm", floatValue/1000000.0f];
    if (floatValue > 1000)
        return [NSString stringWithFormat:@"%.02fk", floatValue/1000.0f];
    return [NSString stringWithFormat:@"%.02f", floatValue];
}

@end
