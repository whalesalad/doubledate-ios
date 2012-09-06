//
//  DDAuthenticationController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAuthenticationController.h"
#import <RestKit/RestKit.h>
#import "DDFacebookController.h"
#import <SBJson/SBJson.h>
#import "DDTools.h"
#import "DDRequestsController.h"

NSString *DDAuthenticationControllerAuthenticateDidSucceesNotification = @"DDAuthenticationControllerAuthenticateDidSucceesNotification";
NSString *DDAuthenticationControllerAuthenticateDidFailedNotification = @"DDAuthenticationControllerAuthenticateDidFailedNotification";
NSString *DDAuthenticationControllerAuthenticateDidFailedUserInfoErrorKey = @"DDAuthenticationControllerAuthenticateDidFailedUserInfoErrorKey";
NSString *DDAuthenticationControllerAuthenticateDidFailedUserInfoReasonKey = @"DDAuthenticationControllerAuthenticateDidFailedUserInfoReasonKey";

@interface DDAuthenticationController ()<RKRequestDelegate>

@property(nonatomic, retain) NSString *userId;
@property(nonatomic, retain) NSString *token;

- (void)authenticateWithFbId:(NSString*)fbId fbToken:(NSString*)fbToken;

@end

static DDAuthenticationController *_sharedInstance = nil;

@implementation DDAuthenticationController

@synthesize userId;
@synthesize token;

+ (DDAuthenticationController*)sharedController
{
    if (!_sharedInstance)
        _sharedInstance = [[DDAuthenticationController alloc] init];
    return _sharedInstance;
}

+ (NSString*)token
{
    return [[DDAuthenticationController sharedController] token];
}

+ (NSString*)userId
{
    return [[DDAuthenticationController sharedController] userId];
}

+ (void)authenticateWithFbId:(NSString*)fbId fbToken:(NSString*)fbToken
{
    [[DDAuthenticationController sharedController] authenticateWithFbId:fbId fbToken:fbToken];
}

- (void)authenticateWithFbId:(NSString*)fbId fbToken:(NSString*)fbToken
{
    //create parameters
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:fbId forKey:@"facebook_id"];
    [dictionary setObject:fbToken forKey:@"access_token"];
    
    //create request
    NSString *requestPath = [[DDTools authUrlPath] stringByAppendingPathComponent:@"authenticate"];
    RKRequest *request = [[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]];
    request.method = RKRequestMethodPOST;
    request.HTTPBody = [[[[SBJsonWriter alloc] init] autorelease] dataWithObject:dictionary];
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //send request
    [controller_ startRequest:request];
}

- (id)init
{
    if ((self = [super init]))
    {
        controller_ = [[DDRequestsController alloc] init];
        controller_.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    controller_.delegate = nil;
    [controller_ stopAllRequests];
    [controller_ release];
    [userId release];
    [token release];
    [super dealloc];
}

#pragma mark -
#pragma comment RKRequestDelegate

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    //save data
    NSDictionary *dictionary = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
    [[DDAuthenticationController sharedController] setUserId:[dictionary objectForKey:@"user_id"]];
    [[DDAuthenticationController sharedController] setToken:[dictionary objectForKey:@"token"]];
    
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:DDAuthenticationControllerAuthenticateDidSucceesNotification object:self];
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    //set user info
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:DDAuthenticationControllerAuthenticateDidFailedError] forKey:DDAuthenticationControllerAuthenticateDidFailedUserInfoReasonKey];
    [userInfo setObject:error forKey:DDAuthenticationControllerAuthenticateDidFailedUserInfoErrorKey];
    
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:DDAuthenticationControllerAuthenticateDidFailedNotification object:self userInfo:userInfo];
}

- (void)requestDidCancelLoad:(RKRequest *)request
{
    //set user info
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:DDAuthenticationControllerAuthenticateDidFailedCancel] forKey:DDAuthenticationControllerAuthenticateDidFailedUserInfoReasonKey];
    
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:DDAuthenticationControllerAuthenticateDidFailedNotification object:self userInfo:userInfo];
}

- (void)requestDidTimeout:(RKRequest *)request
{
    //set user info
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:DDAuthenticationControllerAuthenticateDidFailedCancel] forKey:DDAuthenticationControllerAuthenticateDidFailedUserInfoReasonKey];
    
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:DDAuthenticationControllerAuthenticateDidFailedNotification object:self userInfo:userInfo];
}

@end
