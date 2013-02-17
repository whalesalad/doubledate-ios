//
//  DDRequestsController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDRequestsController.h"
#import <RestKit/RestKit.h>
#import "DDFacebookController.h"
#import "SBJson.h"
#import "DDTools.h"
#import "DDAuthenticationController.h"
#import "DDUser.h"

@interface DDRequestsController () <RKRequestDelegate>

- (void)stopRequest:(RKRequest*)request;

@end

@implementation DDRequestsController

@synthesize delegate;
@synthesize requests=requests_;

static DDRequestsController *_sharedDummyInstance = nil;
static DDRequestsController *_sharedMeInstance = nil;

+ (DDRequestsController*)sharedDummyController
{
    if (!_sharedDummyInstance)
        _sharedDummyInstance = [[DDRequestsController alloc] init];
    return _sharedDummyInstance;
}

+ (DDRequestsController*)sharedMeController
{
    if (!_sharedMeInstance)
        _sharedMeInstance = [[DDRequestsController alloc] init];
    return _sharedMeInstance;
}

- (id)init
{
    if ((self = [super init]))
    {
        requests_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)startRequest:(RKRequest*)request
{
    request.delegate = self;
    [requests_ addObject:request];
    [request sendAsynchronously];
}

- (void)stopRequest:(RKRequest*)request
{
    request.delegate = nil;
    [request cancel];
    [[request retain] autorelease];
    [requests_ removeObject:request];
}

- (void)stopAllRequests
{
    while ([requests_ count])
        [self stopRequest:[requests_ lastObject]];
}

- (void)dealloc
{
    [self stopAllRequests];
    [requests_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark RKRequestDelegate

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    //check me request
    if (request.delegate == _sharedMeInstance)
    {
        if (response.statusCode == 200)
        {
            NSDictionary *dictionary = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
            [DDAuthenticationController setCurrentUser:[[[DDUser alloc] initWithDictionary:dictionary] autorelease]];
        }
    }
    
    //inform delegate
    [self.delegate request:request didLoadResponse:response];
    
    //stop request
    [self stopRequest:request];
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    //inform delegate
    [self.delegate request:request didFailLoadWithError:error];
    
    //stop request
    [self stopRequest:request];
}

- (void)requestDidCancelLoad:(RKRequest *)request
{
    //inform delegate
    [self.delegate requestDidCancelLoad:request];
    
    //stop request
    [self stopRequest:request];
}

- (void)requestDidTimeout:(RKRequest *)request
{
    //inform delegate
    [self.delegate requestDidTimeout:request];
    
    //stop request
    [self stopRequest:request];
}

@end
