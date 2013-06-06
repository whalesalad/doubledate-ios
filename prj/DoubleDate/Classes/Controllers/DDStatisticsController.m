//
//  DDStatisticsController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDStatisticsController.h"
#import "Mixpanel.h"

NSString *DDStatisticsControllerEventWelcomeLoad = @"Welcome View Displayed";
NSString *DDStatisticsControllerEventWelcomeFBTap = @"Welcome View, Why FB? Tapped";
NSString *DDStatisticsControllerEventWelcomeLoginTap = @"Welcome View, Login Tapped";
NSString *DDStatisticsControllerEventInviteFromFB = @"Tapped Invite from FB Friend List";
NSString *DDStatisticsControllerEventCreateDateLoad = @"Create DoubleDate Started";
NSString *DDStatisticsControllerEventCreateDateChooseWing = @"Create DoubleDate, Chose Wing";
NSString *DDStatisticsControllerEventCreateDateComplete = @"Create DoubleDate, Complete";
NSString *DDStatisticsControllerEventCreateDateCancelled = @"Create DoubleDate, Cancelled";
NSString *DDStatisticsControllerEventSession = @"Session";
NSString *DDStatisticsControllerUserBrowsedDates = @"User Browsed Dates";
NSString *DDStatisticsControllerUserViewedDate = @"User Viewed a Date";
NSString *DDStatisticsControllerUserOpenedBubble = @"User Opened a Bubble";

@implementation DDStatisticsController

+ (void)initialize
{
    [Mixpanel sharedInstanceWithToken:@"e3c54d5bdd57b7d06e543e3156e0f6d2"];
}

+ (void)setName:(NSString*)name
{
    [[Mixpanel sharedInstance] setNameTag:name];
}

+ (void)registerProperties:(NSDictionary*)properties
{
    [[Mixpanel sharedInstance] registerSuperProperties:properties];
}

+ (void)trackEvent:(NSString*)event
{
    NSLog(@"DDStatistics tracking: %@", event);
    [[Mixpanel sharedInstance] track:event];
}

+ (void)trackEvent:(NSString*)event withProperties:(NSDictionary*)properties
{
    NSLog(@"DDStatistics tracking: %@, with properties: %@", event, properties);
    [[Mixpanel sharedInstance] track:event properties:properties];
}

@end
