//
//  DDStatisticsController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *DDStatisticsControllerEventWelcomeLoad;
extern NSString *DDStatisticsControllerEventWelcomeFBTap;
extern NSString *DDStatisticsControllerEventWelcomeLoginTap;
extern NSString *DDStatisticsControllerEventInviteFromFB;
extern NSString *DDStatisticsControllerEventCreateDateLoad;
extern NSString *DDStatisticsControllerEventCreateDateChooseWing;
extern NSString *DDStatisticsControllerEventCreateDateComplete;
extern NSString *DDStatisticsControllerEventCreateDateCancelled;
extern NSString *DDStatisticsControllerEventSession;

@interface DDStatisticsController : NSObject
{
}

+ (void)setName:(NSString*)name;

+ (void)registerProperties:(NSDictionary*)properties;

+ (void)trackEvent:(NSString*)event;
+ (void)trackEvent:(NSString*)event withProperties:(NSDictionary*)properties;

@end
