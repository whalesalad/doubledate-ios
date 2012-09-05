//
//  DDFacebookController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDFacebookController.h"
#import <FacebookSDK/FacebookSDK.h>

NSString* DDFacebookControllerSessionDidLoginNotification = @"DDFacebookControllerSessionDidLoginNotification";
NSString* DDFacebookControllerSessionDidNotLoginNotification = @"DDFacebookControllerSessionDidNotLoginNotification";
NSString* DDFacebookControllerSessionDidNotLoginUserInfoErrorKey = @"DDFacebookControllerSessionDidNotLoginUserInfoErrorKey";

NSString *DDFacebookControllerSessionDidGetMeNotification = @"DDFacebookControllerSessionDidGetMeNotification";
NSString *DDFacebookControllerSessionDidGetMeUserInfoObjectKey = @"DDFacebookControllerSessionDidGetMeUserInfoObjectKey";
NSString *DDFacebookControllerSessionDidNotGetMeNotification = @"DDFacebookControllerSessionDidNotGetMeNotification";
NSString *DDFacebookControllerSessionDidNotGetMeUserInfoErrorKey = @"DDFacebookControllerSessionDidNotGetMeUserInfoErrorKey";

@implementation DDFacebookController

static DDFacebookController *_sharedInstance = nil;

+ (DDFacebookController*)sharedController
{
    if (!_sharedInstance)
        _sharedInstance = [[DDFacebookController alloc] init];
    return _sharedInstance;
}

- (void)login
{
    [FBSession openActiveSessionWithPermissions:[NSArray arrayWithObjects:@"email", @"user_birthday", @"user_location", nil]
                                   allowLoginUI:YES
                              completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                  if (!error)
                                  {
                                      [[NSNotificationCenter defaultCenter] postNotificationName:DDFacebookControllerSessionDidLoginNotification object:self];
                                  }
                                  else
                                  {
                                      NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:DDFacebookControllerSessionDidNotLoginUserInfoErrorKey];
                                      [[NSNotificationCenter defaultCenter] postNotificationName:DDFacebookControllerSessionDidNotLoginNotification object:self userInfo:userInfo];
                                  }
                              }];
}

- (void)logout
{
    [[FBSession activeSession] closeAndClearTokenInformation];
}

- (void)requestMe
{
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error)
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:result forKey:DDFacebookControllerSessionDidGetMeUserInfoObjectKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:DDFacebookControllerSessionDidGetMeNotification object:self userInfo:userInfo];
        }
        else
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:DDFacebookControllerSessionDidNotGetMeUserInfoErrorKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:DDFacebookControllerSessionDidNotGetMeNotification object:self userInfo:userInfo];
        }
    }];
}

@end
