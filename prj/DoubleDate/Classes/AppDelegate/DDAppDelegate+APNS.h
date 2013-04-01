//
//  DDAppDelegate+APNS.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAppDelegate.h"

extern NSString *DDAppDelegateAPNSDidReceiveRemoteNotification;
extern NSString *DDAppDelegateAPNSWillOpenCallbackUrlNotification;
extern NSString *DDAppDelegateAPNSDidCloseCallbackUrlNotification;

@interface DDAPNSPayload : NSObject

@property(nonatomic, retain) NSString *callbackUrl;
@property(nonatomic, retain) NSNumber *notificationId;
@property(nonatomic, retain) NSNumber *hasDialog;

@end

@interface DDAppDelegate (APNS)

- (void)registerForRemoteNotifications;
- (void)unregisterFromRemoteNotifications;
- (BOOL)sendMyDevice;
- (void)handleNotificationPayload:(DDAPNSPayload*)payload;

@end
