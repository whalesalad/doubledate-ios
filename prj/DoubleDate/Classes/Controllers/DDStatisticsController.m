//
//  DDStatisticsController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDStatisticsController.h"
#import "Mixpanel.h"

NSString *DDStatisticsEventWelcomeLoad = @"Welcome View Displayed";
NSString *DDStatisticsEventWelcomeFBTap = @"Welcome View, Why FB? Tapped";
NSString *DDStatisticsEventWelcomeLoginTap = @"Welcome View, Login Tapped";
NSString *DDStatisticsEventInviteFromFB = @"Tapped Invite from FB Friend List";
NSString *DDStatisticsEventCreateDateLoad = @"Create DoubleDate Started";
NSString *DDStatisticsEventCreateDateChooseWing = @"Create DoubleDate, Chose Wing";
NSString *DDStatisticsEventCreateDateComplete = @"Create DoubleDate, Complete";
NSString *DDStatisticsEventCreateDateCancelled = @"Create DoubleDate, Cancelled";
NSString *DDStatisticsEventCreateDateDidInviteGhost = @"Create DoubleDate, Sent Facebook Request to Ghost";
NSString *DDStatisticsEventCreateDateSkippedInviteGhost = @"Create DoubleDate, Skipped sending Facebook Request to Ghost";
NSString *DDStatisticsEventSession = @"Session";
NSString *DDStatisticsUserBrowsedDates = @"User Browsed Dates";
NSString *DDStatisticsUserViewedDate = @"User Viewed a Date";
NSString *DDStatisticsUserOpenedBubble = @"User Opened a Bubble";

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
