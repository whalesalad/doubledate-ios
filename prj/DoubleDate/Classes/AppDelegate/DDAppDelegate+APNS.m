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
#import "DDBarButtonItem.h"
#import <RestKit/RestKit.h>
#import <SBJson.h>

NSString *DDAppDelegateAPNSDidReceiveRemoteNotification = @"DDAppDelegateAPNSDidReceiveRemoteNotification";
NSString *DDAppDelegateAPNSWillOpenCallbackUrlNotification = @"DDAppDelegateAPNSWillOpenCallbackUrlNotification";
NSString *DDAppDelegateAPNSDidCloseCallbackUrlNotification = @"DDAppDelegateAPNSDidCloseCallbackUrlNotification";

@implementation DDAPNSPayload

@synthesize callbackUrl;
@synthesize notificationId;

- (void)dealloc
{
    [callbackUrl release];
    [notificationId release];
    [super dealloc];
}

@end

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
    //notify
    [[NSNotificationCenter defaultCenter] postNotificationName:DDAppDelegateAPNSDidReceiveRemoteNotification object:userInfo];
    
    //check if we need to open new view controller
    if ([application applicationState] != UIApplicationStateActive)
    {
        //set payload
        DDAPNSPayload *p = [[[DDAPNSPayload alloc] init] autorelease];
        p.callbackUrl = [[userInfo objectForKey:APNS_CALLBACK_URL_KEY] stringValue];
        p.notificationId = [[userInfo objectForKey:APNS_NOTIFICATION_ID_KEY] stringValue];
        if (p.callbackUrl && p.notificationId)
            [self handleNotificationPayload:p];
    }
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

- (void)presentModalViewController:(UIViewController*)vc
{
    //send notification
    [[NSNotificationCenter defaultCenter] postNotificationName:DDAppDelegateAPNSWillOpenCallbackUrlNotification object:self.openedPayload];
    
    //wrap view controller into the navigaton controller
    UINavigationController *nc = [[[DDNavigationController alloc] initWithRootViewController:vc] autorelease];
    
    //present view controller
    [self.topNavigationController presentViewController:nc animated:YES completion:^{
    }];
    
    //set left bar buton item
    vc.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Close", nil) target:self action:@selector(dismissModalViewController)];
}

- (void)dismissModalViewController
{
    //dismiss view controller
    [self.topNavigationController dismissViewControllerAnimated:YES completion:^{
    }];
    
    //send notification
    [[NSNotificationCenter defaultCenter] postNotificationName:DDAppDelegateAPNSDidCloseCallbackUrlNotification object:self.openedPayload];
}

- (void)handleNotificationPayload:(DDAPNSPayload*)payload
{
    //only authenticated users can handle
    if ([DDAuthenticationController currentUser])
    {
        //show loading hud
        [self.window.rootViewController showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
        
        //save callback url to open
        self.openedPayload = payload;
        
        //make api request
        NSString *path = payload.callbackUrl;
        path = [path stringByReplacingOccurrencesOfString:@"dbld8://" withString:@""];
        DDAPIControllerMethodType requestType = -1;
        if ([path rangeOfString:@"users"].location != NSNotFound)
            requestType = DDAPIControllerMethodTypeGetUser;
        else if ([path rangeOfString:@"engagements"].location != NSNotFound)
            requestType = DDAPIControllerMethodTypeGetEngagement;
        else if ([path rangeOfString:@"activities"].location != NSNotFound)
            requestType = DDAPIControllerMethodTypeGetDoubleDate;
        if (requestType != -1)
            [self.apiController requestForPath:path withMethod:RKRequestMethodGET ofType:requestType];
    }
    else
        self.payload = payload;
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
        [self presentModalViewController:viewController];
    }
    else if ([object isKindOfClass:[DDDoubleDate class]])
    {
        //hide hud
        [self.window.rootViewController hideHud:YES];
        
        //push view controller
        DDDoubleDateViewController *viewController = [[[DDDoubleDateViewController alloc] init] autorelease];
        viewController.doubleDate = (DDDoubleDate*)object;
        [self presentModalViewController:viewController];
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
    [self presentModalViewController:viewController];
}

- (void)getDoubleDateDidFailedWithError:(NSError *)error
{
    //hide hud
    [self.window.rootViewController hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
