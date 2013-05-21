//
//  DDStatisticksController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *DDStatisticksControllerEventWelcomeLoad;
extern NSString *DDStatisticksControllerEventWelcomeFBTap;
extern NSString *DDStatisticksControllerEventWelcomeLoginTap;
extern NSString *DDStatisticksControllerEventInviteFromFB;
extern NSString *DDStatisticksControllerEventCreateDateLoad;
extern NSString *DDStatisticksControllerEventCreateDateChooseWing;
extern NSString *DDStatisticksControllerEventCreateDateComplete;
extern NSString *DDStatisticksControllerEventCreateDateCancelled;
extern NSString *DDStatisticksControllerEventSession;

@interface DDStatisticksController : NSObject
{
}

+ (void)setName:(NSString*)name;

+ (void)registerProperties:(NSDictionary*)properties;

+ (void)trackEvent:(NSString*)event;
+ (void)trackEvent:(NSString*)event withProperties:(NSDictionary*)properties;

@end
