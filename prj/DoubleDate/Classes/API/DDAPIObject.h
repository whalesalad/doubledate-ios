//
//  DDAPIObject.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDAPIObject : NSObject
{
}

+ (id)objectWithDictionary:(NSDictionary*)dictionary;
+ (id)objectWithJsonString:(NSString*)string;
+ (id)objectWithJsonData:(NSData*)data;

+ (NSString*)stringForObject:(id)object;
+ (NSDictionary*)dictionaryForObject:(id)object;

- (id)initWithDictionary:(NSDictionary*)dictionary;

- (NSDictionary*)dictionaryRepresentation;

@end
