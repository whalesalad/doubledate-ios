//
//  DDStatisticsController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDUser.h"

extern NSString *DDStatisticsEventWelcomeLoad;
extern NSString *DDStatisticsEventWelcomeFBTap;
extern NSString *DDStatisticsEventWelcomeLoginTap;
extern NSString *DDStatisticsEventInviteFromFB;
extern NSString *DDStatisticsEventCreateDateLoad;
extern NSString *DDStatisticsEventCreateDateChooseWing;
extern NSString *DDStatisticsEventCreateDateComplete;
extern NSString *DDStatisticsEventCreateDateCancelled;
extern NSString *DDStatisticsEventCreateDateDidInviteGhost;
extern NSString *DDStatisticsEventCreateDateSkippedInviteGhost;
extern NSString *DDStatisticsEventSentEngagementDidInviteGhost;
extern NSString *DDStatisticsEventSentEngagementSkippedInviteGhost;
extern NSString *DDStatisticsEventSession;
extern NSString *DDStatisticsUserBrowsedDates;
extern NSString *DDStatisticsUserViewedDate;
extern NSString *DDStatisticsUserOpenedBubble;


@interface DDStatisticsController : NSObject
{
}

+ (void)setName:(NSString*)name;
+ (void)setUser:(DDUser*)user;

+ (void)registerProperties:(NSDictionary*)properties;

+ (void)trackEvent:(NSString*)event;
+ (void)trackEvent:(NSString*)event withProperties:(NSDictionary*)properties;

@end
