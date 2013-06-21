//
//  DDStatisticsController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDStatisticsController.h"
#import "DDUser.h"

//#import "Mixpanel.h"
#import "Analytics/Analytics.h"

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
NSString *DDStatisticsEventSentEngagementDidInviteGhost = @"Sent Engagement, Sent Facebook Request to Ghost";
NSString *DDStatisticsEventSentEngagementSkippedInviteGhost = @"Sent Engagement, Skipped sending Facebook Request to Ghost";
NSString *DDStatisticsEventSession = @"Session";
NSString *DDStatisticsUserBrowsedDates = @"User Browsed Dates";
NSString *DDStatisticsUserViewedDate = @"User Viewed a Date";
NSString *DDStatisticsUserOpenedBubble = @"User Opened a Bubble";

@implementation DDStatisticsController

+ (void)initialize
{
    [Analytics withSecret:@"fi31zj6ejhs4amywwgsh"];
//    [Mixpanel sharedInstanceWithToken:@"e3c54d5bdd57b7d06e543e3156e0f6d2"];
}

+ (void)setName:(NSString*)name
{
//    [[Mixpanel sharedInstance] setNameTag:name];
}

+ (void)setUser:(DDUser*)user
{
    //apply name
//    [DDStatisticsController setName:[NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName]];
    //register user id
//    [DDStatisticsController registerProperties:[NSDictionary dictionaryWithObjectsAndKeys:user.uuid, @"username", nil]];
    [[Analytics sharedAnalytics] identify:user.uuid];
}

+ (void)registerProperties:(NSDictionary*)properties
{
//    [[Mixpanel sharedInstance] registerSuperProperties:properties];
}

+ (void)trackEvent:(NSString*)event
{
    NSLog(@"DDStatistics tracking: %@", event);
//    [[Mixpanel sharedInstance] track:event];
    [[Analytics sharedAnalytics] track:event];
}

+ (void)trackEvent:(NSString*)event withProperties:(NSDictionary*)properties
{
    NSLog(@"DDStatistics tracking: %@, with properties: %@", event, properties);
//    [[Mixpanel sharedInstance] track:event properties:properties];
    [[Analytics sharedAnalytics] track:event properties:properties];
}

@end
