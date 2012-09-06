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
