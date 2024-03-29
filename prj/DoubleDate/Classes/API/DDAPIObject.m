//
//  DDAPIObject.m
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAPIObject.h"
#import "SBJson.h"
#import "DDTools.h"

@implementation DDAPIObject

@synthesize uniqueKey;
@synthesize uniqueKeyField;

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

+ (NSDictionary*)dictionaryForObject:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]])
        return [NSDictionary dictionaryWithDictionary:object];
    return nil;
}

+ (NSArray*)arrayForObject:(id)object
{
    if ([object isKindOfClass:[NSArray class]])
        return [NSArray arrayWithArray:object];
    return nil;
}

+ (NSArray*)numberForObject:(id)object
{
    if ([object isKindOfClass:[NSNumber class]])
        return [[object copy] autorelease];
    return nil;
}

+ (NSDate*)dateForObject:(id)object
{
    if ([object isKindOfClass:[NSDate class]])
        return [[object retain] autorelease];
    else if ([object isKindOfClass:[NSString class]])
        return [DDTools dateFromString:object];
    return nil;
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if (![dictionary isKindOfClass:[NSDictionary class]])
        return nil;
    if ((self = [self init]))
    {
        dictionary_ = [dictionary retain];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    return nil;
}

- (id)copyWithZone:(NSZone*)zone
{
    return [[[self class] allocWithZone:zone] initWithDictionary:[self dictionaryRepresentation]];
}

- (NSDictionary*)source
{
    return dictionary_;
}

- (void)dealloc
{
    [dictionary_ release];
    [super dealloc];
}

@end
