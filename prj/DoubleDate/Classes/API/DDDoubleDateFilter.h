//
//  DDDoubleDateFilter.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

@class DDPlacemark;

extern NSString *DDDoubleDateFilterHappeningWeekday;
extern NSString *DDDoubleDateFilterHappeningWeekend;

@interface DDDoubleDateFilter : NSObject
{
}

@property(nonatomic, retain) NSString *happening;
@property(nonatomic, retain) NSNumber *minAge;
@property(nonatomic, retain) NSNumber *maxAge;
@property(nonatomic, retain) NSString *query;
@property(nonatomic, retain) DDPlacemark *location;

- (NSString*)queryString;

@end
