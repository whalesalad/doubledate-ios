//
//  DDAuthenticationController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDRequestsController;
@class DDUser;

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
extern NSString *DDAuthenticationControllerAuthenticateDidFailedUserInfoCodeKey;
extern NSString *DDAuthenticationControllerAuthenticateDidFailedUserInfoResponseCodeKey;
extern NSString *DDAuthenticationControllerAuthenticateUserInfoDelegateKey;

@interface DDAuthenticationController : NSObject
{
    DDRequestsController *controller_;
}

+ (BOOL)isNewUser;

+ (NSString*)token;
+ (void)clearToken;

+ (void)authenticateWithFbToken:(NSString*)fbToken delegate:(id)delegate;
+ (void)authenticateWithEmail:(NSString*)email password:(NSString*)password delegate:(id)delegate;
+ (void)logout;

+ (void)setCurrentUser:(DDUser*)user;
+ (DDUser*)currentUser;
+ (void)updateCurrentUser;

@end
