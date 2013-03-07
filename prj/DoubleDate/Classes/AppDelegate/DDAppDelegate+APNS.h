//
//  DDAppDelegate+APNS.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAppDelegate.h"

extern NSString *DDAppDelegateAPNSDidReceiveRemoteNotification;
extern NSString *DDAppDelegateAPNSWillOpenCallbackUrlNotification;
extern NSString *DDAppDelegateAPNSDidCloseCallbackUrlNotification;

@interface DDAPNSPayload : NSObject

@property(nonatomic, retain) NSString *callbackUrl;
@property(nonatomic, retain) NSString *notificationId;

@end

@interface DDAppDelegate (APNS)

- (void)registerForRemoteNotifications;
- (void)unregisterFromRemoteNotifications;
- (BOOL)sendMyDevice;
- (void)handleNotificationPayload:(DDAPNSPayload*)payload;

@end
