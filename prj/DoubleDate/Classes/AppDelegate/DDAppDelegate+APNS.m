//
//  DDAppDelegate+APNS.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAppDelegate+APNS.h"
#import "DDAPIController.h"
#import "DDTools.h"
#import "DDAuthenticationController.h"
#import "UIViewController+Extensions.h"
#import "DDUser.h"
#import "DDMeViewController.h"
#import "DDDoubleDate.h"
#import "DDDoubleDateViewController.h"
#import "DDEngagement.h"
#import "DDChatViewController.h"
#import <RestKit/RestKit.h>
#import <SBJson.h>

@implementation DDAppDelegate (APNS)

- (void)registerForRemoteNotifications
{
    //request device token
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

- (void)unregisterFromRemoteNotifications
{
    //unregister from device token
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token
{
    //save device token
	self.deviceToken = [[[token description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //send device token
    [self sendMyDevice];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	NSLog(@"Error while receiving device token: %@", [error localizedDescription]);
	self.deviceToken = nil;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if ([[userInfo objectForKey:@"callback_url"] isKindOfClass:[NSString class]])
        [self handleNotificationUrl:[userInfo objectForKey:@"callback_url"]];
}

- (BOOL)sendMyDevice
{
    //check if device token exist
    if (self.deviceToken)
    {              
        //create request
        NSString *requestPath = [[DDTools authUrlPath] stringByAppendingPathComponent:@"/me/device"];
        RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
        request.method = RKRequestMethodPUT;
        request.HTTPBody = [[[[SBJsonWriter alloc] init] autorelease] dataWithObject:[NSDictionary dictionaryWithObject:self.deviceToken forKey:@"device_token"]];
        NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
        NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
        request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        //send request
        [[DDRequestsController sharedDummyController] startRequest:request];
        
        return YES;
    }
    
    return NO;
}

- (void)handleNotificationUrl:(NSString*)callbackUrl
{
    //only authenticated users can handle
    if ([DDAuthenticationController currentUser])
    {
        //show loading hud
        [self.window.rootViewController showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
        
        //make api request
        NSString *path = callbackUrl;
        path = [path stringByReplacingOccurrencesOfString:@"dbld8://" withString:@""];
        DDAPIControllerMethodType requestType = -1;
        if ([path rangeOfString:@"users"].location != NSNotFound)
            requestType = DDAPIControllerMethodTypeGetUser;
        else if ([path rangeOfString:@"engagements"].location != NSNotFound)
            requestType = DDAPIControllerMethodTypeGetEngagement;
        else if ([path rangeOfString:@"activities"].location != NSNotFound)
            requestType = DDAPIControllerMethodTypeGetDoubleDate;
        assert(requestType != -1);
        [self.apiController requestForPath:path withMethod:RKRequestMethodGET ofType:requestType];
    }
}

- (void)requestDidSucceed:(NSObject*)object
{
    //check received object
    if ([object isKindOfClass:[DDUser class]])
    {
        //hide hud
        [self.window.rootViewController hideHud:YES];
        
        //push view controller
        DDMeViewController *viewController = [[[DDMeViewController alloc] init] autorelease];
        viewController.user = (DDUser*)object;
        [self.topNavigationController pushViewController:viewController animated:YES];
    }
    else if ([object isKindOfClass:[DDDoubleDate class]])
    {
        //hide hud
        [self.window.rootViewController hideHud:YES];
        
        //push view controller
        DDDoubleDateViewController *viewController = [[[DDDoubleDateViewController alloc] init] autorelease];
        viewController.doubleDate = (DDDoubleDate*)object;
        [self.topNavigationController pushViewController:viewController animated:YES];
    }
    else if ([object isKindOfClass:[DDEngagement class]])
    {
        //save selected engagement
        self.selectedEngagement = (DDEngagement*)object;
        
        //get doubledate
        DDDoubleDate *doubleDate = [[[DDDoubleDate alloc] init] autorelease];
        doubleDate.identifier = [self.selectedEngagement activityId];
        [self.apiController getDoubleDate:doubleDate];
    }
}

- (void)requestDidFailedWithError:(NSError*)error
{
    //hide hud
    [self.window.rootViewController hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)getDoubleDateSucceed:(DDDoubleDate *)doubleDate
{
    //hide hud
    [self.window.rootViewController hideHud:YES];
    
    //push view controller
    DDChatViewController *viewController = [[[DDChatViewController alloc] init] autorelease];
    viewController.doubleDate = doubleDate;
    viewController.engagement = self.selectedEngagement;
    [self.topNavigationController pushViewController:viewController animated:YES];
}

- (void)getDoubleDateDidFailedWithError:(NSError *)error
{
    //hide hud
    [self.window.rootViewController hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
