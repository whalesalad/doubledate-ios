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
#import "DDUserLocation.h"

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
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[user dictionaryRepresentation] forKey:@"user"];
        
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
    //check response code
    if (response.statusCode == 201 || response.statusCode == 200)
    {
        //create user object
        DDUser *user = [DDUser objectWithDictionary:[[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body]];
        
        //check method
        if ([request.userData isKindOfClass:[NSString class]] && [request.userData isEqualToString:DDAPIControllerMethodIdentifierMe])
        {
            //inform delegate
            if ([self.delegate respondsToSelector:@selector(getMeDidSucceed:)])
                [self.delegate getMeDidSucceed:user];
        }
        else if ([request.userData isKindOfClass:[NSString class]] && [request.userData isEqualToString:DDAPIControllerMethodIdentifierCreate])
        {
            //inform delegate
            if ([self.delegate respondsToSelector:@selector(createUserSucceed:)])
                [self.delegate createUserSucceed:user];
        }
    }
    else
    {
        //save error message
        NSString *errorMessage = NSLocalizedString(@"Internal server error", nil);
        NSString *responseMessage = [DDTools errorMessageFromResponseData:response.body];
        if (responseMessage)
            errorMessage = responseMessage;
        
        //create error
        NSError *error = [NSError errorWithDomain:@"DDDomain" code:-1 userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]];
        
        //redirect to self
        [self request:request didFailLoadWithError:error];
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    //check method
    if ([request.userData isKindOfClass:[NSString class]] && [request.userData isEqualToString:DDAPIControllerMethodIdentifierMe])
    {
        //inform delegate
        if ([self.delegate respondsToSelector:@selector(getMeDidFailedWithError:)])
            [self.delegate getMeDidFailedWithError:error];
    }
    else if ([request.userData isKindOfClass:[NSString class]] && [request.userData isEqualToString:DDAPIControllerMethodIdentifierCreate])
    {
        //inform delegate
        if ([self.delegate respondsToSelector:@selector(createUserDidFailedWithError:)])
            [self.delegate createUserDidFailedWithError:error];
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
        if ([self.delegate respondsToSelector:@selector(getMeDidFailedWithError:)])
            [self.delegate getMeDidFailedWithError:error];
    }
    else if ([request.userData isKindOfClass:[NSString class]] && [request.userData isEqualToString:DDAPIControllerMethodIdentifierCreate])
    {
        //inform delegate
        if ([self.delegate respondsToSelector:@selector(createUserDidFailedWithError:)])
            [self.delegate createUserDidFailedWithError:error];
    }
}

- (void)requestDidTimeout:(RKRequest *)request
{
    //create error
    NSError *error = [NSError errorWithDomain:@"DDDomain" code:DDErrorTypeTimeout userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Timeout", nil) forKey:NSLocalizedDescriptionKey]];
    
    //check method
    if ([request.userData isKindOfClass:[NSString class]] && [request.userData isEqualToString:DDAPIControllerMethodIdentifierMe])
    {
        //inform delegate
        if ([self.delegate respondsToSelector:@selector(getMeDidFailedWithError:)])
            [self.delegate getMeDidFailedWithError:error];
    }
    else if ([request.userData isKindOfClass:[NSString class]] && [request.userData isEqualToString:DDAPIControllerMethodIdentifierCreate])
    {
        //inform delegate
        if ([self.delegate respondsToSelector:@selector(createUserDidFailedWithError:)])
            [self.delegate createUserDidFailedWithError:error];
    }
}


@end
