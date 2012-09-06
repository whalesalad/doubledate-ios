//
//  DDAPIObject.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAPIObject.h"
#import <SBJson/SBJson.h>

@implementation DDAPIObject

+ (id)objectWithDictionary:(NSDictionary*)dictionary
{
    return [[[[self class] alloc] initWithDictionary:dictionary] autorelease];
}

+ (id)objectWithJsonString:(NSString*)string
{
    NSDictionary *dictionary = [[[[SBJsonParser alloc] init] autorelease] objectWithString:string];
    return [DDAPIObject objectWithDictionary:dictionary];
}

+ (id)objectWithJsonData:(NSData*)data
{
    NSDictionary *dictionary = [[[[SBJsonParser alloc] init] autorelease] objectWithData:data];
    return [DDAPIObject objectWithDictionary:dictionary];
}

+ (NSString*)stringForObject:(id)object
{
    if ([object isKindOfClass:[NSString class]])
        return [NSString stringWithString:object];
    else if ([object isKindOfClass:[NSNumber class]])
        return [object stringValue];
    return nil;
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [self init]))
    {
        
    }
    return self;
}

@end
