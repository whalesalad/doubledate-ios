//
//  DDEngagement.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAPIObject.h"

extern NSString *DDEngagementStatusLocked;
extern NSString *DDEngagementStatusUnlocked;

@class DDShortUser;

@interface DDEngagement : DDAPIObject
{
}

@property(nonatomic, retain) NSNumber *identifier;
@property(nonatomic, retain) NSNumber *userId;
@property(nonatomic, retain) NSNumber *wingId;
@property(nonatomic, retain) NSString *message;
@property(nonatomic, retain) NSString *primaryMessage;
@property(nonatomic, retain) NSString *status;
@property(nonatomic, retain) NSNumber *messagesCount;
@property(nonatomic, retain) NSNumber *unreadCount;
@property(nonatomic, retain) NSString *createdAt;
@property(nonatomic, retain) NSString *createdAtAgo;
@property(nonatomic, retain) DDShortUser *user;
@property(nonatomic, retain) DDShortUser *wing;

@end
