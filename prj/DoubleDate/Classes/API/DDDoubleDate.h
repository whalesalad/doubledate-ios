//
//  DDDoubleDate.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.//

#import "DDAPIObject.h"

@class DDShortUser;
@class DDPlacemark;
@class DDEngagement;

extern NSString *DDDoubleDateRelationshipOpen;
extern NSString *DDDoubleDateRelationshipOwner;
extern NSString *DDDoubleDateRelationshipWing;
extern NSString *DDDoubleDateRelationshipEngaged;

@interface DDDoubleDate : DDAPIObject
{
}

@property(nonatomic, retain) NSNumber *identifier;
@property(nonatomic, retain) NSString *relationship;
@property(nonatomic, retain) NSString *details;
@property(nonatomic, retain) NSDate *updatedAt;
@property(nonatomic, retain) NSDate *createdAt;
@property(nonatomic, retain) NSNumber *myEngagementId;
@property(nonatomic, retain) NSNumber *unreadCount;
@property(nonatomic, retain) DDShortUser *user;
@property(nonatomic, retain) DDShortUser *wing;
@property(nonatomic, retain) DDPlacemark *location;
@property(nonatomic, retain) DDEngagement *engagement;

@end
