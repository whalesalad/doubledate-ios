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

static DDFacebookController *_sharedInstance = nil;

@implementation DDFacebookController

+ (DDFacebookController*)sharedController
{
    if (!_sharedInstance)
        _sharedInstance = [[DDFacebookController alloc] init];
    return _sharedInstance;
}

+ (NSString*)token
{
    return [[FBSession activeSession] accessToken];
}

- (void)login
{
    //logout first
    [self logout];
    
    //unset flag
    __block BOOL alreadyLoggedIn = NO;

    //save permissions
    NSMutableArray *permissions = [NSMutableArray array];
    [permissions addObject:@"email"];
    [permissions addObject:@"user_about_me"];
    [permissions addObject:@"user_status"];
    [permissions addObject:@"user_activities"];
    [permissions addObject:@"user_birthday"];
    [permissions addObject:@"user_interests"];
    [permissions addObject:@"user_location"];
    [permissions addObject:@"user_photos"];
    [permissions addObject:@"user_relationships"];
    [permissions addObject:@"user_relationship_details"];
    [permissions addObject:@"friends_status"];
    [permissions addObject:@"friends_location"];

    //open session
    [FBSession openActiveSessionWithPermissions:permissions
                                   allowLoginUI:YES
                              completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                  if (!error)
                                  {
                                      if (state == FBSessionStateOpen && !alreadyLoggedIn)
                                      {
                                          alreadyLoggedIn = YES;
                                          [[NSNotificationCenter defaultCenter] postNotificationName:DDFacebookControllerSessionDidLoginNotification object:self];
                                      }
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
