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
#import "DDAppDelegate.h"
#import "DDAppDelegate+APNS.h"
#import "DDUser.h"

NSString *DDAuthenticationControllerAuthenticateDidSucceesNotification = @"DDAuthenticationControllerAuthenticateDidSucceesNotification";
NSString *DDAuthenticationControllerAuthenticateDidFailedNotification = @"DDAuthenticationControllerAuthenticateDidFailedNotification";
NSString *DDAuthenticationControllerAuthenticateDidFailedUserInfoErrorKey = @"DDAuthenticationControllerAuthenticateDidFailedUserInfoErrorKey";
NSString *DDAuthenticationControllerAuthenticateDidFailedUserInfoReasonKey = @"DDAuthenticationControllerAuthenticateDidFailedUserInfoReasonKey";
NSString *DDAuthenticationControllerAuthenticateDidFailedUserInfoCodeKey = @"DDAuthenticationControllerAuthenticateDidFailedUserInfoCodeKey";
NSString *DDAuthenticationControllerAuthenticateDidFailedUserInfoResponseCodeKey = @"DDAuthenticationControllerAuthenticateDidFailedUserInfoResponseCodeKey";
NSString *DDAuthenticationControllerAuthenticateUserInfoDelegateKey = @"DDAuthenticationControllerAuthenticateUserInfoDelegateKey";

@interface DDAuthenticationController ()<RKRequestDelegate>

@property(nonatomic, retain) NSObject *token;
@property(nonatomic, retain) NSObject *user;
@property(nonatomic, retain) NSNumber *isNewUser;

- (void)authenticateWithFbToken:(NSString*)fbToken email:(NSString*)email password:(NSString*)password delegate:(id)delegate;

@end

static DDAuthenticationController *_sharedInstance = nil;

@implementation DDAuthenticationController

@synthesize token;
@synthesize user;
@synthesize isNewUser;

+ (DDAuthenticationController*)sharedController
{
    if (!_sharedInstance)
        _sharedInstance = [[DDAuthenticationController alloc] init];
    return _sharedInstance;
}

+ (BOOL)isNewUser
{
    return [[[DDAuthenticationController sharedController] isNewUser] boolValue];
}

+ (NSString*)token
{
//    return @"f9cc7fe401336a462c534ca0e78a85f0fcf44e5b";
    NSObject *ret = [[DDAuthenticationController sharedController] token];
    if ([ret isKindOfClass:[NSNumber class]])
        return [(NSNumber*)ret stringValue];
    else if ([ret isKindOfClass:[NSString class]])
        return (NSString*)ret;
    return nil;
}

+ (void)clearToken
{
    [[DDAuthenticationController sharedController] setToken:nil];
}

+ (void)setCurrentUser:(DDUser*)user
{
    [[DDAuthenticationController sharedController] setUser:user];
    [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] updateApplicationBadge];
}

+ (DDUser*)currentUser
{
    NSObject *user = [[DDAuthenticationController sharedController] user];
    if ([user isKindOfClass:[DDUser class]])
        return (DDUser*)user;
    return nil;
}

+ (void)updateCurrentUser
{
    if ([self currentUser])
    {
        //create request
        NSString *requestPath = [[DDTools authUrlPath] stringByAppendingPathComponent:@"/me"];
        RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
        request.method = RKRequestMethodGET;
        NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
        NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
        request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        //send request
        [[DDRequestsController sharedMeController] startRequest:request];
    }
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

+ (void)logout
{
    //send a logout request
    {
        //create request
        NSString *requestPath = [[DDTools authUrlPath] stringByAppendingPathComponent:@"/logout"];
        RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
        request.method = RKRequestMethodGET;
        NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
        NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
        request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        //send request
        [[DDRequestsController sharedDummyController] startRequest:request];
    }
    
    //clear token
    [DDAuthenticationController clearToken];
    
    //unset current user
    [DDAuthenticationController setCurrentUser:nil];
}

- (void)heartbeat:(id)sender
{
    //save device token
    NSString *deviceToken = [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] deviceToken];
    
    //check device toke
    if (deviceToken)
    {
        //create request
        NSString *requestPath = [[DDTools authUrlPath] stringByAppendingPathComponent:@"/me/device"];
        RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
        request.method = RKRequestMethodPUT;
        request.HTTPBody = [[[[SBJsonWriter alloc] init] autorelease] dataWithObject:[NSDictionary dictionaryWithObject:deviceToken forKey:@"device_token"]];
        NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
        NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
        request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        //send request
        [[DDRequestsController sharedDummyController] startRequest:request];
    }
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
    [token release];
    [user release];
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
        [[DDAuthenticationController sharedController] setToken:[dictionary objectForKey:@"token"]];
        [[DDAuthenticationController sharedController] setIsNewUser:[dictionary objectForKey:@"new_user"]];
        
        //register for remote notifications
        [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] registerForRemoteNotifications];
        
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
        NSString *errorMessage = NSLocalizedString(@"Oops. An unfortunate DoubleDate error has occurred.", nil);
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
        NSError *error = [NSError errorWithDomain:DDErrorDomain code:-1 userInfo:userInfo];
        
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
