//
//  DDDoubleDate.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAPIObject.h"

@class DDShortUser;

extern NSString *DDDoubleDateDayPrefWeekday;
extern NSString *DDDoubleDateDayPrefWeekend;
extern NSString *DDDoubleDateTimePrefDaytime;
extern NSString *DDDoubleDateTimePrefNighttime;

@interface DDDoubleDate : DDAPIObject
{
}

@property(nonatomic, retain) NSNumber *identifier;
@property(nonatomic, retain) NSString *status;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *details;
@property(nonatomic, retain) NSString *dayPref;
@property(nonatomic, retain) NSString *timePref;
@property(nonatomic, retain) NSNumber *userId;
@property(nonatomic, retain) NSNumber *wingId;
@property(nonatomic, retain) NSString *updatedAt;
@property(nonatomic, retain) NSNumber *locationId;
@property(nonatomic, retain) DDShortUser *user;
@property(nonatomic, retain) DDShortUser *wing;

@end
