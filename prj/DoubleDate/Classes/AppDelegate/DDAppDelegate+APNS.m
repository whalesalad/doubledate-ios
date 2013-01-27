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

@end
