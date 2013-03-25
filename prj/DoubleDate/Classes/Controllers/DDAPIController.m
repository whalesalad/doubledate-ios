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
#import "SBJson.h"
#import "DDTools.h"
#import "DDAuthenticationController.h"
#import "DDUser.h"
#import "DDPlacemark.h"
#import "DDInterest.h"
#import "DDImage.h"
#import "DDShortUser.h"
#import "DDDoubleDate.h"
#import "DDDoubleDateFilter.h"
#import "DDEngagement.h"
#import "DDMessage.h"
#import "DDNotification.h"
#import "DDObjectsController.h"
#import "DDMaxActivitiesPayload.h"
#import "DDInAppProduct.h"
 
@interface DDAPIControllerUserData : NSObject

@property(nonatomic, assign) DDAPIControllerMethodType method;
@property(nonatomic, assign) SEL succeedSel;
@property(nonatomic, assign) SEL failedSel;
@property(nonatomic, retain) NSObject *userData;

@end

@implementation DDAPIControllerUserData

@synthesize method;
@synthesize succeedSel;
@synthesize failedSel;
@synthesize userData;

- (void)dealloc
{
    [userData release];
    [super dealloc];
}

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

- (void)clearRequest:(RKRequest*)request
{
    request.delegate = nil;
    request.params = nil;
}

- (DDRequestId)startRequest:(RKRequest*)request
{
    DDRequestId requestId = [request hash];
    [controller_ startRequest:request];
    return requestId;
}

- (BOOL)isRequestExist:(DDRequestId)requestId
{
    for (RKRequest *request in [controller_ requests])
    {
        if ([request hash] == requestId)
            return YES;
    }
    return NO;
}

- (BOOL)cancelRequest:(DDRequestId)requestId
{
    for (RKRequest *request in [controller_ requests])
    {
        if ([request hash] == requestId)
        {
            [request cancel];
            return YES;
        }
    }
    return NO;
}

- (NSString*)pathForRequest:(DDRequestId)requestId
{
    for (RKRequest *request in [controller_ requests])
    {
        if ([request hash] == requestId)
            return [[request URL] absoluteString];
    }
    return nil;
}

- (DDRequestId)requestForPath:(NSString*)urlPath withMethod:(RKRequestMethod)method ofType:(DDAPIControllerMethodType)type
{
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:urlPath];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = method;
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = type;
    userData.succeedSel = @selector(requestDidSucceed:);
    userData.failedSel = @selector(requestDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)getMe
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"me"];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetMe;
    userData.succeedSel = @selector(getMeDidSucceed:);
    userData.failedSel = @selector(getMeDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)getUser:(DDUser*)user
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"users/%d", [user.userId intValue]]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Authorization", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetUser;
    userData.succeedSel = @selector(getUserDidSucceed:);
    userData.failedSel = @selector(getUserDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)updateMe:(DDUser*)user
{
    //create user dictionary
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[user dictionaryRepresentation] forKey:@"user"];
    
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"me"];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodPUT;
    request.HTTPBody = [[[[SBJsonWriter alloc] init] autorelease] dataWithObject:dictionary];
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeUpdateMe;
    userData.succeedSel = @selector(updateMeSucceed:);
    userData.failedSel = @selector(updateMeDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)updatePhotoForMe:(UIImage*)photo
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"me/photo"];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodPOST;
    RKParams *params = [RKParams params];
    RKParamsAttachment *attachement = [params setData:UIImagePNGRepresentation(photo) MIMEType:@"image/png" forParam:@"image"];
    attachement.fileName = @"image.png";
    request.params = params;
    NSArray *keys = [NSArray arrayWithObjects:@"Authorization", nil];
    NSArray *objects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeUpdatePhotoForMe;
    userData.succeedSel = @selector(updatePhotoForMeSucceed:);
    userData.failedSel = @selector(updatePhotoForMeDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)updatePhotoForMeFromFacebook
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"me/photo/pull_facebook"];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodPOST;
    NSArray *keys = [NSArray arrayWithObjects:@"Authorization", nil];
    NSArray *objects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeUpdatePhotoForMeFromFacebook;
    userData.succeedSel = @selector(updatePhotoForMeFromFacebookSucceed:);
    userData.failedSel = @selector(updatePhotoForMeFromFacebookDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)createUser:(DDUser*)user
{
    //create user dictionary
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[user dictionaryRepresentation] forKey:@"user"];
        
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"users"];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
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
    return [self startRequest:request];
}

- (DDRequestId)requestFacebookUserForToken:(NSString*)fbToken
{
    //create user dictionary
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:fbToken forKey:@"facebook_access_token"];
    
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"users/build"];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
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
    return [self startRequest:request];
}

- (DDRequestId)searchPlacemarksForLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
{
    return [self searchPlacemarksForLatitude:latitude longitude:longitude query:nil options:DDLocationSearchOptionsBoth];
}

- (DDRequestId)searchPlacemarksForLatitude:(CGFloat)latitude longitude:(CGFloat)longitude query:(NSString*)query
{
    return [self searchPlacemarksForLatitude:latitude longitude:longitude query:query options:DDLocationSearchOptionsBoth];
}

- (DDRequestId)searchPlacemarksForLatitude:(CGFloat)latitude longitude:(CGFloat)longitude options:(DDLocationSearchOptions)options
{
    return [self searchPlacemarksForLatitude:latitude longitude:longitude query:nil options:options];
}

- (DDRequestId)searchPlacemarksForLatitude:(CGFloat)latitude longitude:(CGFloat)longitude query:(NSString*)query options:(DDLocationSearchOptions)options
{
    return [self searchPlacemarksForLatitude:latitude longitude:longitude query:query options:options distance:0];
}

- (DDRequestId)searchPlacemarksForLatitude:(CGFloat)latitude longitude:(CGFloat)longitude query:(NSString*)query options:(DDLocationSearchOptions)options distance:(NSInteger)distance
{
    //set parameters
    NSString *params = [NSString string];
    
    //check for valid values
    if (latitude != 0 && longitude != 0)
        params = [NSString stringWithFormat:@"latitude=%f&longitude=%f", latitude, longitude];
    
    //add distance if needed
    if (distance > 0)
        params = [NSString stringWithFormat:@"%@%@distance=%d", params, [params length]?@"&":@"", distance];
    
    //add query if needed
    if ([query length])
        params = [NSString stringWithFormat:@"%@%@query=%@", params, [params length]?@"&":@"", [query stringByAddingURLEncoding]];
    
    //create request
    NSString *requestPath = nil;
    switch (options) {
        case DDLocationSearchOptionsCities:
            requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"locations/cities"];
            break;
        case DDLocationSearchOptionsVenues:
            requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"locations/venues"];
            break;
        case DDLocationSearchOptionsBoth:
            requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"locations/both"];
            break;
        default:
            break;
    }
    if ([params length])
        requestPath = [requestPath stringByAppendingFormat:@"?%@", params];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    NSMutableArray *keys = [NSMutableArray arrayWithObjects:@"Accept", @"Content-Type", nil];
    NSMutableArray *objects = [NSMutableArray arrayWithObjects:@"application/json", @"application/json", nil];
    if ([[DDAuthenticationController token] length])
    {
        [keys addObject:@"Authorization"];
        [objects addObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]]];
    }
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeSearchPlacemarks;
    userData.succeedSel = @selector(searchPlacemarksSucceed:forQuery:);
    userData.failedSel = @selector(searchPlacemarksDidFailedWithError:);
    userData.userData = query;
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)requestAvailableInterests
{
    return [self requestAvailableInterestsWithQuery:nil];
}

- (DDRequestId)requestAvailableInterestsWithQuery:(NSString*)query
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"interests"];
    if ([query length])
        requestPath = [NSString stringWithFormat:@"%@?query=%@", requestPath, [query stringByAddingURLEncoding]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeRequestAvailableInterests;
    userData.succeedSel = @selector(requestAvailableInterestsSucceed:);
    userData.failedSel = @selector(requestAvailableInterestsDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)getFriends
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"me/friends"];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetFriends;
    userData.succeedSel = @selector(getFriendsSucceed:);
    userData.failedSel = @selector(getFriendsDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)requestApproveFriendshipForFriend:(DDShortUser*)friend
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"me/friends/%d", [friend.identifier intValue]]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodPUT;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeRequestApproveFriendshipForFriend;
    userData.succeedSel = @selector(requestApproveFriendshipForFriendSucceed:);
    userData.failedSel = @selector(requestApproveFriendshipForFriendDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)requestDenyFriendshipForFriend:(DDShortUser*)friend
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"me/friends/%d", [friend.identifier intValue]]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodDELETE;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeRequestDenyFriendshipForFriend;
    userData.succeedSel = @selector(requestDenyFriendshipForFriendSucceed);
    userData.failedSel = @selector(requestDenyFriendshipForFriendDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)requestDeleteFriend:(DDShortUser*)user
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"me/friends/%d", [user.identifier intValue]]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodDELETE;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeRequestDeleteFriend;
    userData.succeedSel = @selector(requestDeleteFriendSucceed);
    userData.failedSel = @selector(requestDeleteFriendDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)getFriend:(DDShortUser*)user
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"users/%d", [user.identifier intValue]]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetFriend;
    userData.succeedSel = @selector(getFriendSucceed:);
    userData.failedSel = @selector(getFriendDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)getFacebookFriends
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"me/friends/facebook"]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetFacebookFriends;
    userData.succeedSel = @selector(getFacebookFriendsSucceed:);
    userData.failedSel = @selector(getFacebookFriendsDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)requestInvitationsForFBUsers:(NSArray*)fbIds andDDUsers:(NSArray*)ddIds
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"me/friends/invite"]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodPOST;
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //set http body
    NSDictionary *dictionary = [NSMutableDictionary dictionary];
    if ([fbIds count])
    {
        NSMutableArray *numberValues = [NSMutableArray array];
        for (NSObject *num in fbIds)
        {
            if ([num isKindOfClass:[NSNumber class]])
                [numberValues addObject:num];
            else if ([num isKindOfClass:[NSString class]])
                [numberValues addObject:[NSNumber numberWithLongLong:[(NSString*)num longLongValue]]];
        }
        [dictionary setValue:numberValues forKey:@"facebook_ids"];
    }
    if ([ddIds count])
    {
        NSMutableArray *numberValues = [NSMutableArray array];
        for (NSObject *num in ddIds)
        {
            if ([num isKindOfClass:[NSNumber class]])
                [numberValues addObject:num];
            else if ([num isKindOfClass:[NSString class]])
                [numberValues addObject:[NSNumber numberWithLongLong:[(NSString*)num longLongValue]]];
        }
        [dictionary setValue:numberValues forKey:@"user_ids"];
    }
    request.HTTPBody = [[[[SBJsonWriter alloc] init] autorelease] dataWithObject:dictionary];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeRequestInvitations;
    userData.succeedSel = @selector(requestInvitationsSucceed:);
    userData.failedSel = @selector(requestInvitationsDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)createDoubleDate:(DDDoubleDate*)doubleDate
{
    //create user dictionary
    NSDictionary *dictionary = [doubleDate dictionaryRepresentation];
    
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"activities"];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodPOST;
    request.HTTPBody = [[[[SBJsonWriter alloc] init] autorelease] dataWithObject:dictionary];
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeCreateDoubleDate;
    userData.succeedSel = @selector(createDoubleDateSucceed:);
    userData.failedSel = @selector(createDoubleDateDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)getDoubleDatesWithFilter:(DDDoubleDateFilter*)filter
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"activities"];
    if ([[filter queryString] length])
        requestPath = [NSString stringWithFormat:@"%@?%@", requestPath, [filter queryString]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetDoubleDates;
    userData.succeedSel = @selector(getDoubleDatesSucceed:);
    userData.failedSel = @selector(getDoubleDatesDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)getMyDoubleDates
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"activities/mine"];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetMyDoubleDates;
    userData.succeedSel = @selector(getMyDoubleDatesSucceed:);
    userData.failedSel = @selector(getMyDoubleDatesDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)getDoubleDate:(DDDoubleDate*)doubleDate
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"activities/%d", [doubleDate.identifier intValue]]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetDoubleDate;
    userData.succeedSel = @selector(getDoubleDateSucceed:);
    userData.failedSel = @selector(getDoubleDateDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)requestDeleteDoubleDate:(DDDoubleDate*)doubleDate
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"activities/%d", [doubleDate.identifier intValue]]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodDELETE;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeRequestDeleteDoubleDate;
    userData.succeedSel = @selector(requestDeleteDoubleDateSucceed);
    userData.failedSel = @selector(requestDeleteDoubleDateDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)getEngagements
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"/engagements"];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetEngagements;
    userData.succeedSel = @selector(getEngagementsSucceed:);
    userData.failedSel = @selector(getEngagementsDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)getEngagement:(DDEngagement*)engagement
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"engagements/%d", [engagement.identifier intValue]]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetEngagement;
    userData.succeedSel = @selector(getEngagementSucceed:);
    userData.failedSel = @selector(getEngagementDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)createEngagement:(DDEngagement*)engagement
{
    //create user dictionary
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[engagement dictionaryRepresentation] forKey:@"engagement"];
    
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"engagements"]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodPOST;
    request.HTTPBody = [[[[SBJsonWriter alloc] init] autorelease] dataWithObject:dictionary];
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeCreateEngagement;
    userData.succeedSel = @selector(createEngagementSucceed:);
    userData.failedSel = @selector(createEngagementDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)unlockEngagement:(DDEngagement*)engagement
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"engagements/%d/unlock", [engagement.identifier intValue]]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodPOST;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeUnlockEngagement;
    userData.succeedSel = @selector(unlockEngagementSucceed:);
    userData.failedSel = @selector(unlockEngagementDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)requestDeleteEngagement:(DDEngagement*)engagement
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"engagements/%d", [engagement.identifier intValue]]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodDELETE;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeRequestDeleteEngagement;
    userData.succeedSel = @selector(requestDeleteEngagementSucceed);
    userData.failedSel = @selector(requestDeleteEngagementDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)getMessagesForEngagement:(DDEngagement*)engagement
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"engagements/%d/messages", [engagement.identifier intValue]]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetMessages;
    userData.succeedSel = @selector(getMessagesForEngagementSucceed:);
    userData.failedSel = @selector(getMessagesForEngagementDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)createMessage:(DDMessage*)message forEngagement:(DDEngagement*)engagement
{
    //create user dictionary
    NSDictionary *dictionary = [message dictionaryRepresentation];
    
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"engagements/%d/messages", [engagement.identifier intValue]]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodPOST;
    request.HTTPBody = [[[[SBJsonWriter alloc] init] autorelease] dataWithObject:dictionary];
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeCreateMessage;
    userData.succeedSel = @selector(createMessageSucceed:);
    userData.failedSel = @selector(createMessageDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)getNotifications
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"me/notifications"]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetNotifications;
    userData.succeedSel = @selector(getNotificationsSucceed:);
    userData.failedSel = @selector(getNotificationsDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)getNotification:(DDNotification*)notification
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"me/notifications/%d", [notification.identifier intValue]]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetNotification;
    userData.succeedSel = @selector(getNotificationSucceed:);
    userData.failedSel = @selector(getNotificationDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)updateNotification:(DDNotification*)notification
{
    //create user dictionary
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[notification dictionaryRepresentation] forKey:@"notification"];
    
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"me/notifications/%d", [notification.identifier intValue]]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodPUT;
    request.HTTPBody = [[[[SBJsonWriter alloc] init] autorelease] dataWithObject:dictionary];
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeUpdateNotification;
    userData.succeedSel = @selector(updateNotificationSucceed:);
    userData.failedSel = @selector(updateNotificationDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)getMeUnlockMaxActivities
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"me/unlock/max_activities"]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetMeUnlockMaxActivities;
    userData.succeedSel = @selector(getMeUnlockMaxActivitiesSucceed:);
    userData.failedSel = @selector(getMeUnlockMaxActivitiesDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)unlockMeMaxActivities:(DDMaxActivitiesPayload*)payload
{
    //set parameters
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:payload.slug forKey:@"slug"];
    
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"me/unlock"]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodPOST;
    request.HTTPBody = [[[[SBJsonWriter alloc] init] autorelease] dataWithObject:dictionary];
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeUnlockMeMaxActivities;
    userData.succeedSel = @selector(unlockMeMaxActivitiesSucceed:);
    userData.failedSel = @selector(unlockMeMaxActivitiesDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)getInAppProducts
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"packages"]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetInAppProducts;
    userData.succeedSel = @selector(getInAppProductsSucceed:);
    userData.failedSel = @selector(getInAppProductsDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)requestConnectFriends:(NSString*)fbFriends
{
    //set parameters
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:fbFriends forKey:@"request_ids"];
    
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"me/friends/request_connect"]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodPOST;
    request.HTTPBody = [[[[SBJsonWriter alloc] init] autorelease] dataWithObject:dictionary];
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeRequestConnectFriends;
    userData.succeedSel = @selector(requestConnectFriendsSucceed:);
    userData.failedSel = @selector(requestConnectFriendsDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)requestInviteFriend:(NSString*)slug
{
    //set parameters
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:slug forKey:@"invite_slug"];
    
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"me/friends/invite_connect"]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodPOST;
    request.HTTPBody = [[[[SBJsonWriter alloc] init] autorelease] dataWithObject:dictionary];
    NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeRequestInviteFriend;
    userData.succeedSel = @selector(requestInviteFriendSucceed:);
    userData.failedSel = @selector(requestInviteFriendDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

#pragma mark -
#pragma mark RKRequestDelegate

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    //extract user data
    DDAPIControllerUserData *userData = (DDAPIControllerUserData*)request.userData;
    if (![userData isKindOfClass:[DDAPIControllerUserData class]])
    {
        [self clearRequest:request];
        return;
    }
    
    //check response code and method name
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204)
    {
        //check type
        if (userData.method == DDAPIControllerMethodTypeGetMe ||
            userData.method == DDAPIControllerMethodTypeUpdateMe ||
            userData.method == DDAPIControllerMethodTypeCreateUser ||
            userData.method == DDAPIControllerMethodTypeRequestFBUser ||
            userData.method == DDAPIControllerMethodTypeGetFriend ||
            userData.method == DDAPIControllerMethodTypeGetUser)
        {
            //create user object
            DDUser *user = [DDUser objectWithDictionary:[[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body]];
            
            //notify objects controller
            [DDObjectsController updateObject:user withMethod:request.method cachePath:nil];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:user withObject:userData.userData];
        }
        else if (userData.method == DDAPIControllerMethodTypeSearchPlacemarks)
        {
            //extract data
            NSMutableArray *placemarks = [NSMutableArray array];
            NSArray *responseData = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
            for (NSDictionary *dic in responseData)
            {
                //create object
                DDPlacemark *placemark = [DDPlacemark objectWithDictionary:dic];
                if (placemark)
                    [placemarks addObject:placemark];
            }
            
            //notify objects controller
            [DDObjectsController updateObjects:placemarks withMethod:request.method cachePath:nil];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:placemarks withObject:userData.userData];
        }
        else if (userData.method == DDAPIControllerMethodTypeRequestAvailableInterests)
        {
            //extract data
            NSMutableArray *interests = [NSMutableArray array];
            NSArray *responseData = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
            for (NSDictionary *dic in responseData)
            {
                //create object
                DDInterest *interest = [DDInterest objectWithDictionary:dic];
                if (interest)
                    [interests addObject:interest];
            }
            
            //notify objects controller
            [DDObjectsController updateObjects:interests withMethod:request.method cachePath:nil];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:interests withObject:userData.userData];
        }
        else if (userData.method == DDAPIControllerMethodTypeUpdatePhotoForMe ||
                 userData.method == DDAPIControllerMethodTypeUpdatePhotoForMeFromFacebook)
        {
            //create photo object
            DDImage *photo = [DDImage objectWithDictionary:[[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body]];
            
            //notify objects controller
            [DDObjectsController updateObject:photo withMethod:request.method cachePath:nil];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:photo withObject:userData.userData];
        }
        else if (userData.method == DDAPIControllerMethodTypeGetFriends ||
                 userData.method == DDAPIControllerMethodTypeRequestConnectFriends)
        {
            //extract data
            NSMutableArray *users = [NSMutableArray array];
            NSArray *responseData = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
            for (NSDictionary *dic in responseData)
            {
                //create object
                DDShortUser *user = [DDShortUser objectWithDictionary:dic];
                if (user)
                    [users addObject:user];
            }
            
            //notify objects controller
            [DDObjectsController updateObjects:users withMethod:request.method cachePath:nil];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:users withObject:userData.userData];
        }
        
        else if (userData.method == DDAPIControllerMethodTypeRequestApproveFriendshipForFriend ||
                 userData.method == DDAPIControllerMethodTypeRequestInviteFriend)
        {
            //create friendship object
            DDShortUser *friend = [DDShortUser objectWithDictionary:[[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body]];
            
            //notify objects controller
            [DDObjectsController updateObject:friend withMethod:request.method cachePath:nil];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:friend withObject:userData.userData];
        }
        else if (userData.method == DDAPIControllerMethodTypeRequestDenyFriendshipForFriend ||
                 userData.method == DDAPIControllerMethodTypeRequestDeleteFriend ||
                 userData.method == DDAPIControllerMethodTypeRequestInvitations ||
                 userData.method == DDAPIControllerMethodTypeRequestDeleteDoubleDate ||
                 userData.method == DDAPIControllerMethodTypeRequestDeleteEngagement)
        {
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:nil withObject:userData.userData];
        }
        else if (userData.method == DDAPIControllerMethodTypeGetFacebookFriends)
        {
            //extract data
            NSMutableArray *facebookFriends = [NSMutableArray array];
            NSArray *responseData = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
            for (NSDictionary *dic in responseData)
            {
                //create object
                DDShortUser *facebookUser = [DDShortUser objectWithDictionary:dic];
                if (facebookUser)
                    [facebookFriends addObject:facebookUser];
            }
            
            //notify objects controller
            [DDObjectsController updateObjects:facebookFriends withMethod:request.method cachePath:nil];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:facebookFriends withObject:userData.userData];
        }
        else if (userData.method == DDAPIControllerMethodTypeCreateDoubleDate ||
                 userData.method == DDAPIControllerMethodTypeGetDoubleDate)
        {
            //create object
            DDDoubleDate *doubleDate = [DDDoubleDate objectWithDictionary:[[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body]];
            
            //notify objects controller
            [DDObjectsController updateObject:doubleDate withMethod:request.method cachePath:nil];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:doubleDate withObject:userData.userData];
        }
        else if (userData.method == DDAPIControllerMethodTypeGetDoubleDates ||
                 userData.method == DDAPIControllerMethodTypeGetMyDoubleDates)
        {
            //extract data
            NSMutableArray *doubleDates = [NSMutableArray array];
            NSArray *responseData = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
            for (NSDictionary *dic in responseData)
            {
                //create object
                DDDoubleDate *doubleDate = [DDDoubleDate objectWithDictionary:dic];
                if (doubleDate)
                    [doubleDates addObject:doubleDate];
            }
            
            //notify objects controller
            [DDObjectsController updateObjects:doubleDates withMethod:request.method cachePath:nil];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:doubleDates withObject:userData.userData];
        }
        else if (userData.method == DDAPIControllerMethodTypeGetEngagements)
        {
            //extract data
            NSMutableArray *engagements = [NSMutableArray array];
            NSArray *responseData = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
            for (NSDictionary *dic in responseData)
            {
                //create object
                DDEngagement *engagement = [DDEngagement objectWithDictionary:dic];
                if (engagement)
                    [engagements addObject:engagement];
            }
            
            //notify objects controller
            [DDObjectsController updateObjects:engagements withMethod:request.method cachePath:nil];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:engagements withObject:userData.userData];
        }
        else if (userData.method == DDAPIControllerMethodTypeCreateEngagement ||
                 userData.method == DDAPIControllerMethodTypeUnlockEngagement ||
                 userData.method == DDAPIControllerMethodTypeGetEngagement)
        {
            //create object
            DDEngagement *engagement = [DDEngagement objectWithDictionary:[[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body]];
            
            //notify objects controller
            [DDObjectsController updateObject:engagement withMethod:request.method cachePath:nil];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:engagement withObject:userData.userData];
        }
        else if (userData.method == DDAPIControllerMethodTypeGetMessages)
        {
            //extract data
            NSMutableArray *messages = [NSMutableArray array];
            NSArray *responseData = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
            for (NSDictionary *dic in responseData)
            {
                //create object
                DDMessage *message = [DDMessage objectWithDictionary:dic];
                if (message)
                    [messages addObject:message];
            }
            
            //notify objects controller
            [DDObjectsController updateObjects:messages withMethod:request.method cachePath:request.URL.absoluteString];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:messages withObject:userData.userData];
        }
        else if (userData.method == DDAPIControllerMethodTypeCreateMessage)
        {
            //create object
            DDMessage *message = [DDMessage objectWithDictionary:[[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body]];
            
            //notify objects controller
            [DDObjectsController updateObject:message withMethod:request.method cachePath:request.URL.absoluteString];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:message withObject:userData.userData];
        }
        else if (userData.method == DDAPIControllerMethodTypeGetNotifications)
        {
            //extract data
            NSMutableArray *notifications = [NSMutableArray array];
            NSArray *responseData = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
            for (NSDictionary *dic in responseData)
            {
                //create object
                DDNotification *notification = [DDNotification objectWithDictionary:dic];
                if (notification)
                    [notifications addObject:notification];
            }
            
            //notify objects controller
            [DDObjectsController updateObjects:notifications withMethod:request.method cachePath:request.URL.absoluteString];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:notifications withObject:userData.userData];
        }
        else if (userData.method == DDAPIControllerMethodTypeUpdateNotification ||
                 userData.method == DDAPIControllerMethodTypeGetNotification)
        {
            //create object
            DDNotification *notification = [DDNotification objectWithDictionary:[[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body]];
            
            //notify objects controller
            [DDObjectsController updateObject:notification withMethod:request.method cachePath:request.URL.absoluteString];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:notification withObject:userData.userData];
        }
        else if (userData.method == DDAPIControllerMethodTypeGetMeUnlockMaxActivities ||
                 userData.method == DDAPIControllerMethodTypeUnlockMeMaxActivities)
        {
            //create object
            DDMaxActivitiesPayload *notification = [DDMaxActivitiesPayload objectWithDictionary:[[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body]];
            
            //notify objects controller
            [DDObjectsController updateObject:notification withMethod:request.method cachePath:request.URL.absoluteString];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:notification withObject:userData.userData];
        }
        else if (userData.method == DDAPIControllerMethodTypeGetInAppProducts)
        {
            //extract data
            NSMutableArray *products = [NSMutableArray array];
            NSArray *responseData = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
            for (NSDictionary *dic in responseData)
            {
                //create object
                DDInAppProduct *product = [DDInAppProduct objectWithDictionary:dic];
                if (product)
                    [products addObject:product];
            }
            
            //notify objects controller
            [DDObjectsController updateObjects:products withMethod:request.method cachePath:request.URL.absoluteString];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:products withObject:userData.userData];
        }
    }
    else
    {
        //save error message
        NSString *errorMessage = NSLocalizedString(@"Oops. An unfortunate DoubleDate error has occurred.", nil);
        NSString *responseMessage = [DDTools errorMessageFromResponseData:response.body];
        if (responseMessage)
            errorMessage = responseMessage;
        
        //create error
        NSError *error = [NSError errorWithDomain:DDErrorDomain code:-1 userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]];
        
        //redirect to self
        [self request:request didFailLoadWithError:error];
    }
    
    //clear request
    [self clearRequest:request];
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    //extract user data
    DDAPIControllerUserData *userData = (DDAPIControllerUserData*)request.userData;
    if (![userData isKindOfClass:[DDAPIControllerUserData class]])
        return;
    
    //check method
    if (userData.failedSel && [self.delegate respondsToSelector:userData.failedSel])
        [self.delegate performSelector:userData.failedSel withObject:error withObject:userData.userData];
    
    //clear request
    [self clearRequest:request];
}

- (void)requestDidCancelLoad:(RKRequest *)request
{
    //create error
    NSError *error = [NSError errorWithDomain:DDErrorDomain code:DDErrorTypeCancelled userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Cancelled", nil) forKey:NSLocalizedDescriptionKey]];
    
    //redirect to self
    [self request:request didFailLoadWithError:error];
    
    //clear request
    [self clearRequest:request];
}

- (void)requestDidTimeout:(RKRequest *)request
{
    //create error
    NSError *error = [NSError errorWithDomain:DDErrorDomain code:DDErrorTypeTimeout userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Timeout", nil) forKey:NSLocalizedDescriptionKey]];
    
    //redirect to self
    [self request:request didFailLoadWithError:error];
    
    //clear request
    [self clearRequest:request];
}


@end
