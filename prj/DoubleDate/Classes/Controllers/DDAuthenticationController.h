//
//  DDAuthenticationController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDRequestsController;

typedef enum
{
    DDAuthenticationControllerAuthenticateDidFailedError,
    DDAuthenticationControllerAuthenticateDidFailedCancel,
    DDAuthenticationControllerAuthenticateDidFailedTimeout
} DDAuthenticationControllerAuthenticateDidFailed;

extern NSString *DDAuthenticationControllerAuthenticateDidSucceesNotification;
extern NSString *DDAuthenticationControllerAuthenticateDidFailedNotification;
extern NSString *DDAuthenticationControllerAuthenticateDidFailedUserInfoErrorKey;
extern NSString *DDAuthenticationControllerAuthenticateDidFailedUserInfoReasonKey;

@interface DDAuthenticationController : NSObject
{
    DDRequestsController *controller_;
}

+ (NSString*)token;
+ (NSString*)userId;

+ (void)authenticateWithFbId:(NSString*)fbId fbToken:(NSString*)fbToken;

@end
