//
//  DDStatisticksController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDStatisticksController.h"
#import "Mixpanel.h"

NSString *DDStatisticksControllerEventWelcomeLoad = @"Welcome View Displayed";
NSString *DDStatisticksControllerEventWelcomeFBTap = @"Welcome View, Why FB? Tapped";
NSString *DDStatisticksControllerEventWelcomeLoginTap = @"Welcome View, Login Tapped";
NSString *DDStatisticksControllerEventInviteFromFB = @"Tapped Invite from FB Friend List";
NSString *DDStatisticksControllerEventCreateDateLoad = @"Create DoubleDate Started";
NSString *DDStatisticksControllerEventCreateDateChooseWing = @"Create DoubleDate, Chose Wing";
NSString *DDStatisticksControllerEventCreateDateComplete = @"Create DoubleDate, Complete";
NSString *DDStatisticksControllerEventCreateDateCancelled = @"Create DoubleDate, Cancelled";
NSString *DDStatisticksControllerEventSession = @"Session";

@implementation DDStatisticksController

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
    [[Mixpanel sharedInstance] track:event];
}

+ (void)trackEvent:(NSString*)event withProperties:(NSDictionary*)properties
{
    [[Mixpanel sharedInstance] track:event properties:properties];
}

@end
