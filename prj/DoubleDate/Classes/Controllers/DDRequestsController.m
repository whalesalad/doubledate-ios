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

@interface DDRequestsController () <RKRequestDelegate>

- (void)stopRequest:(RKRequest*)request;

@end

@implementation DDRequestsController

@synthesize delegate;
@synthesize requests=requests_;

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
#pragma comment RKRequestDelegate

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
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
