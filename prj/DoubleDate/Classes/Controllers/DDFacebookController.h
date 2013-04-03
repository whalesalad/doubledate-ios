//
//  DDFacebookController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* DDFacebookControllerSessionDidLoginNotification;
extern NSString* DDFacebookControllerSessionDidNotLoginNotification;
extern NSString* DDFacebookControllerSessionDidNotLoginUserInfoErrorKey;

extern NSString *DDFacebookControllerSessionDidGetMeNotification;
extern NSString *DDFacebookControllerSessionDidGetMeUserInfoObjectKey;
extern NSString *DDFacebookControllerSessionDidNotGetMeNotification;
extern NSString *DDFacebookControllerSessionDidNotGetMeUserInfoErrorKey;

@class FBSession;

@interface DDFacebookController : NSObject
{
}

+ (DDFacebookController*)sharedController;

+ (NSString*)token;

- (void)login;
- (void)logout;
- (void)requestMe;

- (BOOL)isAutoLogin;

@end
