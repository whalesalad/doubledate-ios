//
//  DDDoubleDateFilter.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

@class DDPlacemark;

@interface DDDoubleDateFilter : NSObject<NSCopying>
{
}

@property(nonatomic, retain) NSNumber *minAge;
@property(nonatomic, retain) NSNumber *maxAge;
@property(nonatomic, retain) NSString *query;
@property(nonatomic, retain) DDPlacemark *location;

- (NSString*)queryString;

@end
