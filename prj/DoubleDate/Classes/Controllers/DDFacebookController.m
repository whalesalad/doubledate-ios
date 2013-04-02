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
    FBSession *session = [[[FBSession alloc] initWithPermissions:permissions] autorelease];
    [session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        if (!error)
        {
            if (status == FBSessionStateOpen && !alreadyLoggedIn)
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

/**
 * Attempts to silently open the Facebook session if we have a valid token loaded (that perhaps needs a behind the scenes refresh).
 * After that attempt, we defer to the basic concept of the session being in one of the valid authorized states.
 */
- (BOOL)isLoggedInAfterOpenAttempt {
    NSLog(@"FBSession.activeSession: %@", FBSession.activeSession);

    // If we don't have a cached token, a call to open here would cause UX for login to
    // occur; we don't want that to happen unless the user clicks the login button over in Settings, and so
    // we check here to make sure we have a token before calling open
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        NSLog(@"We have a cached token, so we're going to re-establish the login for the user.");
        // Even though we had a cached token, we need to login to make the session usable:
        [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            NSLog(@"Finished opening login session, with state: %d", status);
        }];
    }
    else
    {
        NSLog(@"Active session state is not 'FBSessionStateCreatedTokenLoaded', it's: %d", FBSession.activeSession.state);
    }
    
    return [self isLoggedIn];
}

- (BOOL)isLoggedIn {
    FBSession *activeSession = [FBSession activeSession];
    FBSessionState state = activeSession.state;
    
    BOOL isLoggedIn = activeSession && [self isSessionStateEffectivelyLoggedIn:state];
    
    NSLog(@"Facebook active session state: %d; logged in conclusion: %@", state, (isLoggedIn ? @"YES" : @"NO"));
    
    return isLoggedIn;
}

- (BOOL)isSessionStateEffectivelyLoggedIn:(FBSessionState)state {
    BOOL effectivelyLoggedIn;
    
    switch (state) {
        case FBSessionStateOpen:
            NSLog(@"Facebook session state: FBSessionStateOpen");
            effectivelyLoggedIn = YES;
            break;
        case FBSessionStateCreatedTokenLoaded:
            NSLog(@"Facebook session state: FBSessionStateCreatedTokenLoaded");
            effectivelyLoggedIn = YES;
            break;
        case FBSessionStateOpenTokenExtended:
            NSLog(@"Facebook session state: FBSessionStateOpenTokenExtended");
            effectivelyLoggedIn = YES;
            break;
        default:
            NSLog(@"Facebook session state: not of one of the open or openable types.");
            effectivelyLoggedIn = NO;
            break;
    }
    
    return effectivelyLoggedIn;
}

@end
