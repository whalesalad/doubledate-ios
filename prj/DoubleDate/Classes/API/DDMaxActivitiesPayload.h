//
//  DDMaxActivitiesPayload.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAPIObject.h"

@interface DDMaxActivitiesPayload : DDAPIObject
{
}

@property(nonatomic, retain) NSNumber *activitiesCount;
@property(nonatomic, retain) NSNumber *activitiesAllowed;
@property(nonatomic, retain) NSNumber *unlockRequired;

@property(nonatomic, retain) NSString *slug;
@property(nonatomic, retain) NSNumber *cost;
@property(nonatomic, retain) NSNumber *maxActivities;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *description;

@end
