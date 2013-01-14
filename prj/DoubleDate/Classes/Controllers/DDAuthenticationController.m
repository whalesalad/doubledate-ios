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
#import "SBJson.h"
#import "DDTools.h"
#import "DDRequestsController.h"

NSString *DDAuthenticationControllerAuthenticateDidSucceesNotification = @"DDAuthenticationControllerAuthenticateDidSucceesNotification";
NSString *DDAuthenticationControllerAuthenticateDidFailedNotification = @"DDAuthenticationControllerAuthenticateDidFailedNotification";
NSString *DDAuthenticationControllerAuthenticateDidFailedUserInfoErrorKey = @"DDAuthenticationControllerAuthenticateDidFailedUserInfoErrorKey";
NSString *DDAuthenticationControllerAuthenticateDidFailedUserInfoReasonKey = @"DDAuthenticationControllerAuthenticateDidFailedUserInfoReasonKey";
NSString *DDAuthenticationControllerAuthenticateDidFailedUserInfoCodeKey = @"DDAuthenticationControllerAuthenticateDidFailedUserInfoCodeKey";
NSString *DDAuthenticationControllerAuthenticateDidFailedUserInfoResponseCodeKey = @"DDAuthenticationControllerAuthenticateDidFailedUserInfoResponseCodeKey";
NSString *DDAuthenticationControllerAuthenticateUserInfoDelegateKey = @"DDAuthenticationControllerAuthenticateUserInfoDelegateKey";

@interface DDAuthenticationController ()<RKRequestDelegate>

@property(nonatomic, retain) NSObject *userId;
@property(nonatomic, retain) NSObject *token;

- (void)authenticateWithFbToken:(NSString*)fbToken email:(NSString*)email password:(NSString*)password delegate:(id)delegate;

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
//    return @"665cb6e04d175affc64e4b304e5a6414045313c7";
    NSObject *ret = [[DDAuthenticationController sharedController] token];
    if ([ret isKindOfClass:[NSNumber class]])
        return [(NSNumber*)ret stringValue];
    else if ([ret isKindOfClass:[NSString class]])
        return (NSString*)ret;
    return nil;
}

+ (NSString*)userId
{
    NSObject *ret = [[DDAuthenticationController sharedController] userId];
    if ([ret isKindOfClass:[NSNumber class]])
        return [(NSNumber*)ret stringValue];
    else if ([ret isKindOfClass:[NSString class]])
        return (NSString*)ret;
    return nil;
}

+ (void)authenticateWithFbToken:(NSString*)fbToken delegate:(id)delegate
{
    [[DDAuthenticationController sharedController] authenticateWithFbToken:fbToken email:nil password:nil delegate:delegate];
}

+ (void)authenticateWithEmail:(NSString*)email password:(NSString*)password delegate:(id)delegate
{
    [[DDAuthenticationController sharedController] authenticateWithFbToken:nil email:email password:password delegate:delegate];
}

- (void)authenticateWithFbToken:(NSString*)fbToken email:(NSString*)email password:(NSString*)password delegate:(id)delegate
{
    //create parameters
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (fbToken)
        [dictionary setObject:fbToken forKey:@"facebook_access_token"];
    if (email)
        [dictionary setObject:email forKey:@"email"];
    if (password)
        [dictionary setObject:password forKey:@"password"];
    
    //create request
    NSString *requestPath = [[DDTools authUrlPath] stringByAppendingPathComponent:@"authenticate"];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodPOST;
    request.HTTPBody = [[[[SBJsonWriter alloc] init] autorelease] dataWithObject:dictionary];
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    request.userData = delegate;
    
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
#pragma mark RKRequestDelegate

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    //check response code
    if (response.statusCode == 200)
    {
        //save data
        NSDictionary *dictionary = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
        [[DDAuthenticationController sharedController] setUserId:[dictionary objectForKey:@"user_id"]];
        [[DDAuthenticationController sharedController] setToken:[dictionary objectForKey:@"token"]];
        
        //set delegate
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        if (request.userData)
            [userInfo setObject:request.userData forKey:DDAuthenticationControllerAuthenticateUserInfoDelegateKey];
        
        //post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:DDAuthenticationControllerAuthenticateDidSucceesNotification object:self userInfo:userInfo];
    }
    else
    {
        //save error message
        NSString *errorMessage = NSLocalizedString(@"Internal server error", nil);
        NSString *responseMessage = [DDTools errorMessageFromResponseData:response.body];
        if (responseMessage)
            errorMessage = responseMessage;
        
        //save internal response code
        NSString *codeMessage = [DDTools codeMessageFromResponseData:response.body];
        
        //generate user info
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:errorMessage forKey:NSLocalizedDescriptionKey];
        [userInfo setObject:[NSNumber numberWithInt:response.statusCode] forKey:DDAuthenticationControllerAuthenticateDidFailedUserInfoResponseCodeKey];
        if (codeMessage)
            [userInfo setObject:codeMessage forKey:DDAuthenticationControllerAuthenticateDidFailedUserInfoCodeKey];
        
        //create error
        NSError *error = [NSError errorWithDomain:@"DDDomain" code:-1 userInfo:userInfo];
        
        //redirect to self
        [self request:request didFailLoadWithError:error];
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    //set user info
    NSMutableDictionary *userInfo = [error userInfo]?[NSMutableDictionary dictionaryWithDictionary:[error userInfo]]:[NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:DDAuthenticationControllerAuthenticateDidFailedError] forKey:DDAuthenticationControllerAuthenticateDidFailedUserInfoReasonKey];
    [userInfo setObject:error forKey:DDAuthenticationControllerAuthenticateDidFailedUserInfoErrorKey];
    if (request.userData)
        [userInfo setObject:request.userData forKey:DDAuthenticationControllerAuthenticateUserInfoDelegateKey];
    
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:DDAuthenticationControllerAuthenticateDidFailedNotification object:self userInfo:userInfo];
}

- (void)requestDidCancelLoad:(RKRequest *)request
{
    //set user info
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:DDAuthenticationControllerAuthenticateDidFailedCancel] forKey:DDAuthenticationControllerAuthenticateDidFailedUserInfoReasonKey];
    if (request.userData)
        [userInfo setObject:request.userData forKey:DDAuthenticationControllerAuthenticateUserInfoDelegateKey];
    
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:DDAuthenticationControllerAuthenticateDidFailedNotification object:self userInfo:userInfo];
}

- (void)requestDidTimeout:(RKRequest *)request
{
    //set user info
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:DDAuthenticationControllerAuthenticateDidFailedCancel] forKey:DDAuthenticationControllerAuthenticateDidFailedUserInfoReasonKey];
    if (request.userData)
        [userInfo setObject:request.userData forKey:DDAuthenticationControllerAuthenticateUserInfoDelegateKey];
    
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:DDAuthenticationControllerAuthenticateDidFailedNotification object:self userInfo:userInfo];
}

@end
