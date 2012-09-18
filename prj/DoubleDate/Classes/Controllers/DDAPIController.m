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
#import "DDPlacemark.h"
#import "DDInterest.h"

typedef enum
{
    DDAPIControllerMethodTypeGetMe,
    DDAPIControllerMethodTypeCreateUser,
    DDAPIControllerMethodTypeRequestFBUser,
    DDAPIControllerMethodTypeSearchPlacemarks,
    DDAPIControllerMethodTypeRequestAvailableInterests,
} DDAPIControllerMethodType;
 
@interface DDAPIControllerUserData : NSObject

@property(nonatomic, assign) DDAPIControllerMethodType method;
@property(nonatomic, assign) SEL succeedSel;
@property(nonatomic, assign) SEL failedSel;

@end

@implementation DDAPIControllerUserData

@end

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
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetMe;
    userData.succeedSel = @selector(getMeDidSucceed:);
    userData.failedSel = @selector(getMeDidFailedWithError:);
    request.userData = userData;
    
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
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeCreateUser;
    userData.succeedSel = @selector(createUserSucceed:);
    userData.failedSel = @selector(createUserDidFailedWithError:);
    request.userData = userData;
    
    //send request
    [controller_ startRequest:request];
}

- (void)requestFacebookUserForToken:(NSString*)fbToken
{
    //create user dictionary
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:fbToken forKey:@"facebook_access_token"];
    
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"users/build"];
    RKRequest *request = [[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]];
    request.method = RKRequestMethodPOST;
    request.HTTPBody = [[[[SBJsonWriter alloc] init] autorelease] dataWithObject:dictionary];
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeRequestFBUser;
    userData.succeedSel = @selector(requestFacebookUserSucceed:);
    userData.failedSel = @selector(requestFacebookDidFailedWithError:);
    request.userData = userData;
    
    //send request
    [controller_ startRequest:request];
}

- (void)searchPlacemarksForLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
{
    //set parameters
    NSString *params = [NSString stringWithFormat:@"latitude=%f&longitude=%f", latitude, longitude];
    
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"locations/search"];
    requestPath = [requestPath stringByAppendingFormat:@"?%@", params];
    RKRequest *request = [[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]];
    request.method = RKRequestMethodGET;
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeSearchPlacemarks;
    userData.succeedSel = @selector(searchPlacemarksSucceed:);
    userData.failedSel = @selector(searchPlacemarksDidFailedWithError:);
    request.userData = userData;
    
    //send request
    [controller_ startRequest:request];
}

- (void)requestAvailableInterests
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"interests"];
    RKRequest *request = [[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]];
    request.method = RKRequestMethodGET;
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeRequestAvailableInterests;
    userData.succeedSel = @selector(requestAvailableInterestsSucceed:);
    userData.failedSel = @selector(requestAvailableInterestsDidFailedWithError:);
    request.userData = userData;
    
    //send request
    [controller_ startRequest:request];
}

#pragma mark -
#pragma comment RKRequestDelegate

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    //extract user data
    DDAPIControllerUserData *userData = (DDAPIControllerUserData*)request.userData;
    if (![userData isKindOfClass:[DDAPIControllerUserData class]])
        return;
    
    //check response code and method name
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204)
    {
        //check type
        if (userData.method == DDAPIControllerMethodTypeGetMe ||
            userData.method == DDAPIControllerMethodTypeCreateUser ||
            userData.method == DDAPIControllerMethodTypeRequestFBUser)
        {
            //create user object
            DDUser *user = [DDUser objectWithDictionary:[[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body]];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:user withObject:nil];
        }
        else if (userData.method == DDAPIControllerMethodTypeSearchPlacemarks)
        {
            //extract data
            NSMutableArray *placemarks = [NSMutableArray array];
            NSArray *responseData = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
            for (NSDictionary *dic in responseData)
            {
                //create placemark
                DDPlacemark *placemark = [DDPlacemark objectWithDictionary:dic];
                if (placemark)
                    [placemarks addObject:placemark];
            }
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:placemarks withObject:nil];
        }
        else if (userData.method == DDAPIControllerMethodTypeRequestAvailableInterests)
        {
            //extract data
            NSMutableArray *interests = [NSMutableArray array];
            NSArray *responseData = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
            for (NSDictionary *dic in responseData)
            {
                //create placemark
                DDInterest *interest = [DDInterest objectWithDictionary:dic];
                if (interest)
                    [interests addObject:interest];
            }
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:interests withObject:nil];
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
    //extract user data
    DDAPIControllerUserData *userData = (DDAPIControllerUserData*)request.userData;
    if (![userData isKindOfClass:[DDAPIControllerUserData class]])
        return;
    
    //check method
    if (userData.failedSel && [self.delegate respondsToSelector:userData.failedSel])
        [self.delegate performSelector:userData.failedSel withObject:error withObject:nil];
}

- (void)requestDidCancelLoad:(RKRequest *)request
{
    //create error
    NSError *error = [NSError errorWithDomain:@"DDDomain" code:DDErrorTypeCancelled userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Cancelled", nil) forKey:NSLocalizedDescriptionKey]];
    
    //redirect to self
    [self request:request didFailLoadWithError:error];
}

- (void)requestDidTimeout:(RKRequest *)request
{
    //create error
    NSError *error = [NSError errorWithDomain:@"DDDomain" code:DDErrorTypeTimeout userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Timeout", nil) forKey:NSLocalizedDescriptionKey]];
    
    //redirect to self
    [self request:request didFailLoadWithError:error];
}


@end
