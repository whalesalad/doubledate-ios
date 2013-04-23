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

+ (NSArray*)permissions
{
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
    [permissions addObject:@"friends_location"];
    return permissions;
}

+ (void)registerServiceWithCompletionBlock:(void (^)(BOOL granted, NSError *error))completionBlock
{
    ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:[self permissions] forKey:ACFacebookPermissionsKey];
    [options setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"] forKey:ACFacebookAppIdKey];
    [accountStore requestAccessToAccountsWithType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook] options:options completion:^(BOOL granted, NSError *error) {
        if (completionBlock)
            completionBlock(granted, error);
    }];
}

- (void)login
{
    //open session
    // FBSession *session = [[[FBSession alloc] initWithPermissions:[DDFacebookController permissions]] autorelease];
    [FBSession openActiveSessionWithReadPermissions:[DDFacebookController permissions]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error)
    {
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
