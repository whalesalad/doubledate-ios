//
//  DDEngagement.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAPIObject.h"

extern NSString *DDEngagementStatusLocked;
extern NSString *DDEngagementStatusUnlocked;
extern NSString *DDEngagementStatusExpired;

@class DDShortUser;

@interface DDEngagement : DDAPIObject
{
}

@property(nonatomic, retain) NSNumber *identifier;
@property(nonatomic, retain) NSNumber *activityId;
@property(nonatomic, retain) NSString *activityTitle;
@property(nonatomic, retain) DDShortUser *activityUser;
@property(nonatomic, retain) DDShortUser *activityWing;
@property(nonatomic, retain) NSNumber *userId;
@property(nonatomic, retain) NSNumber *wingId;
@property(nonatomic, retain) NSNumber *facebookId;
@property(nonatomic, retain) NSString *message;
@property(nonatomic, retain) NSString *primaryMessage;
@property(nonatomic, retain) NSString *status;
@property(nonatomic, retain) NSNumber *unreadCount;
@property(nonatomic, retain) NSString *createdAt;
@property(nonatomic, retain) NSString *createdAtAgo;
@property(nonatomic, retain) NSString *updatedAt;
@property(nonatomic, retain) NSString *updatedAtAgo;
@property(nonatomic, retain) NSString *timeRemaining;
@property(nonatomic, retain) NSNumber *daysRemaining;
@property(nonatomic, retain) DDShortUser *user;
@property(nonatomic, retain) DDShortUser *wing;
@property(nonatomic, retain) NSString *displayName;

@end
