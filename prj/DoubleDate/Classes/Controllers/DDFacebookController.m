//
//  DDFacebookController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
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
    return [[[FBSession activeSession] accessTokenData] accessToken];
}

- (void)login
{
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
    FBSession *session = [[[FBSession alloc] initWithPermissions:permissions] autorelease];
    [session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        if (!error)
        {
            if (FB_ISSESSIONOPENWITHSTATE(status))
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:DDFacebookControllerSessionDidLoginNotification object:self];
            }
        }
        else
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:DDFacebookControllerSessionDidNotLoginUserInfoErrorKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:DDFacebookControllerSessionDidNotLoginNotification object:self userInfo:userInfo];
        }
    }];
    [FBSession setActiveSession:session];
}

- (void)logout
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    [FBSession setActiveSession:nil];
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

- (BOOL)isAutoLogin
{
    __block BOOL autoLogin = NO;
    if ([FBSession activeSession] && FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
    {
        [[FBSession activeSession] openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            autoLogin = FB_ISSESSIONOPENWITHSTATE(status);
        }];
    };
    return autoLogin;
}

@end
