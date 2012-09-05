//
//  DDFacebookController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
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

- (void)login;
- (void)logout;
- (void)requestMe;

@end
