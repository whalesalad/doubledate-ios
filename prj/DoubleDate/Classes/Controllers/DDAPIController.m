//
//  DDAPIController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAPIController.h"
#import <RestKit/RestKit.h>
#import "DDFacebookController.h"
#import <SBJson/SBJson.h>
#import "DDTools.h"
#import "DDAuthenticationController.h"
#import "DDUser.h"

NSString *DDAPIControllerMethodIdentifierMe = @"DDAPIControllerMethodIdentifierMe";
NSString *DDAPIControllerMethodIdentifierCreate = @"DDAPIControllerMethodIdentifierCreate";

@interface DDAPIController ()<RKRequestDelegate>

@end

@implementation DDAPIController

@synthesize delegate;

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
    [controller_ release];
    [super dealloc];
}

- (void)getMe
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"me"];
    RKRequest *request = [[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    request.userData = DDAPIControllerMethodIdentifierMe;
    
    //send request
    [controller_ startRequest:request];
}

- (void)createUser:(DDUser*)user
{
    //create user dictionary
    NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
    if (user.firstName)
        [userDictionary setObject:user.firstName forKey:@"first_name"];
    if (user.lastName)
        [userDictionary setObject:user.lastName forKey:@"last_name"];
    if (user.birthday)
        [userDictionary setObject:user.birthday forKey:@"birthday"];
    if (user.gender)
        [userDictionary setObject:user.gender forKey:@"gender"];
    if (user.interestedIn)
        [userDictionary setObject:user.interestedIn forKey:@"interested_in"];
    [userDictionary setObject:@"123456" forKey:@"password_digest"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:userDictionary forKey:@"user"];
    
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"users"];
    RKRequest *request = [[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]];
    request.method = RKRequestMethodPOST;
    request.HTTPBody = [[[[SBJsonWriter alloc] init] autorelease] dataWithObject:dictionary];
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    request.userData = DDAPIControllerMethodIdentifierCreate;
    
    //send request
    [controller_ startRequest:request];
}

#pragma mark -
#pragma comment RKRequestDelegate

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    //check method
    if ([request.userData isKindOfClass:[NSString class]] && [request.userData isEqualToString:DDAPIControllerMethodIdentifierMe])
    {
        //get response
        NSDictionary *dictionary = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
        
        //create user object
        DDUser *user = [DDUser objectWithDictionary:dictionary];
        
        //inform delegate
        [self.delegate getMeDidSucceed:user];
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    //check method
    if ([request.userData isKindOfClass:[NSString class]] && [request.userData isEqualToString:DDAPIControllerMethodIdentifierMe])
    {
        //inform delegate
        [self.delegate getMeDidFailedWithError:error];
    }
}

- (void)requestDidCancelLoad:(RKRequest *)request
{
    //create error
    NSError *error = [NSError errorWithDomain:@"DDDomain" code:DDErrorTypeCancelled userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Cancelled", nil) forKey:NSLocalizedDescriptionKey]];
    
    //check method
    if ([request.userData isKindOfClass:[NSString class]] && [request.userData isEqualToString:DDAPIControllerMethodIdentifierMe])
    {
        //inform delegate
        [self.delegate getMeDidFailedWithError:error];
    }
}

- (void)requestDidTimeout:(RKRequest *)request
{
    //create error
    NSError *error = [NSError errorWithDomain:@"DDDomain" code:DDErrorTypeTimeout userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Timeout", nil) forKey:NSLocalizedDescriptionKey]];
    
    //check method
    if ([request.userData isKindOfClass:[NSString class]] && [request.userData isEqualToString:DDAPIControllerMethodIdentifierMe])
    {
        [self.delegate getMeDidFailedWithError:error];
    }
}


@end