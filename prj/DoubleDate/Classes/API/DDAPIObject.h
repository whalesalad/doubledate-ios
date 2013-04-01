//
//  DDAPIObject.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDAPIObject : NSObject<NSCopying>
{
}

@property(nonatomic, readonly) NSString *uniqueKey;
@property(nonatomic, readonly) NSString *uniqueKeyField;

+ (id)objectWithDictionary:(NSDictionary*)dictionary;
+ (id)objectWithJsonString:(NSString*)string;
+ (id)objectWithJsonData:(NSData*)data;

+ (NSString*)stringForObject:(id)object;
+ (NSDictionary*)dictionaryForObject:(id)object;
+ (NSArray*)arrayForObject:(id)object;
+ (NSNumber*)numberForObject:(id)object;
+ (NSDate*)dateForObject:(id)object;

- (id)initWithDictionary:(NSDictionary*)dictionary;

- (NSDictionary*)dictionaryRepresentation;

@end
