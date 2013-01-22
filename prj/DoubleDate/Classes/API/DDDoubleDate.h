//
//  DDDoubleDate.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAPIObject.h"

@class DDShortUser;
@class DDPlacemark;

extern NSString *DDDoubleDateDayPrefWeekday;
extern NSString *DDDoubleDateDayPrefWeekend;
extern NSString *DDDoubleDateTimePrefDaytime;
extern NSString *DDDoubleDateTimePrefNighttime;
extern NSString *DDDoubleDateRelationshipOpen;
extern NSString *DDDoubleDateRelationshipOwner;
extern NSString *DDDoubleDateRelationshipWing;
extern NSString *DDDoubleDateRelationshipEngaged;

@interface DDDoubleDate : DDAPIObject
{
}

@property(nonatomic, retain) NSNumber *identifier;
@property(nonatomic, retain) NSString *relationship;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *details;
@property(nonatomic, retain) NSString *dayPref;
@property(nonatomic, retain) NSString *timePref;
@property(nonatomic, retain) NSString *updatedAt;
@property(nonatomic, retain) NSNumber *myEngagementId;
@property(nonatomic, retain) DDShortUser *user;
@property(nonatomic, retain) DDShortUser *wing;
@property(nonatomic, retain) DDPlacemark *location;

@end
