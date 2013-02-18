//
//  DDAppDelegate+APNS.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAppDelegate.h"

extern NSString *DDAppDelegateAPNSDidReceiveRemoteNotification;

@interface DDAppDelegate (APNS)

- (void)registerForRemoteNotifications;
- (void)unregisterFromRemoteNotifications;
- (BOOL)sendMyDevice;
- (void)handleNotificationUrl:(NSString*)callbackUrl;

@end
