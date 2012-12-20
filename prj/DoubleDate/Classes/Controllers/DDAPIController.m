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
#import "DDFriendship.h"
#import "DDShortUser.h"
#import "DDDoubleDate.h"
#import "DDDoubleDateFilter.h"
#import "DDEngagement.h"

typedef enum
{
    DDAPIControllerMethodTypeGetMe,
    DDAPIControllerMethodTypeGetUser,
    DDAPIControllerMethodTypeUpdateMe,
    DDAPIControllerMethodTypeUpdatePhotoForMe,
    DDAPIControllerMethodTypeCreateUser,
    DDAPIControllerMethodTypeRequestFBUser,
    DDAPIControllerMethodTypeSearchPlacemarks,
    DDAPIControllerMethodTypeRequestAvailableInterests,
    DDAPIControllerMethodTypeGetFriends,
    DDAPIControllerMethodTypeGetFriendshipInvitations,
    DDAPIControllerMethodTypeRequestApproveFriendship,
    DDAPIControllerMethodTypeRequestDenyFriendship,
    DDAPIControllerMethodTypeRequestDeleteFriend,
    DDAPIControllerMethodTypeGetFriend,
    DDAPIControllerMethodTypeGetFacebookFriends,
    DDAPIControllerMethodTypeRequestInvitations,
    DDAPIControllerMethodTypeCreateDoubleDate,
    DDAPIControllerMethodTypeGetDoubleDates,
    DDAPIControllerMethodTypeGetMyDoubleDates,
    DDAPIControllerMethodTypeRequestDeleteDoubleDate,
    DDAPIControllerMethodTypeGetEngagements,
    DDAPIControllerMethodTypeCreateEngagement,
    DDAPIControllerMethodTypeGetMessages,
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
        [request cancel];
        return YES;
    }
    return NO;
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
    //set parameters
    NSString *params = [NSString stringWithFormat:@"latitude=%f&longitude=%f", latitude, longitude];
    
    //add query if needed
    if (query)
        params = [NSString stringWithFormat:@"%@&query=%@", params, query];
    
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
    requestPath = [requestPath stringByAppendingFormat:@"?%@", params];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
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
    return [self startRequest:request];
}

- (DDRequestId)requestAvailableInterests
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"interests"];
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

- (DDRequestId)getFriendshipInvitations
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:@"me/friendships/pending"];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetFriendshipInvitations;
    userData.succeedSel = @selector(getFriendshipInvitationsSucceed:);
    userData.failedSel = @selector(getFriendshipInvitationsDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)requestApproveFriendship:(DDFriendship*)friendship
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"me/friendships/%d", [friendship.identifier intValue]]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodPUT;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeRequestApproveFriendship;
    userData.succeedSel = @selector(requestApproveFriendshipSucceed:);
    userData.failedSel = @selector(requestApproveFriendshipDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)requestDenyFriendship:(DDFriendship*)friendship
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"me/friendships/%d", [friendship.identifier intValue]]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodDELETE;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeRequestDenyFriendship;
    userData.succeedSel = @selector(requestDenyFriendshipSucceed);
    userData.failedSel = @selector(requestDenyFriendshipDidFailedWithError:);
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
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"me/friends/%d", [user.identifier intValue]]];
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

- (DDRequestId)getEngagementsForDoubleDate:(DDDoubleDate*)doubleDate
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"activities/%d/engagements", [doubleDate.identifier intValue]]];
    RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
    request.method = RKRequestMethodGET;
    request.additionalHTTPHeaders = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]] forKey:@"Authorization"];
    
    //create user data
    DDAPIControllerUserData *userData = [[[DDAPIControllerUserData alloc] init] autorelease];
    userData.method = DDAPIControllerMethodTypeGetEngagements;
    userData.succeedSel = @selector(getEngagementsForDoubleDateSucceed:);
    userData.failedSel = @selector(getEngagementsForDoubleDateDidFailedWithError:);
    request.userData = userData;
    
    //send request
    return [self startRequest:request];
}

- (DDRequestId)createEngagement:(DDEngagement*)engagement
{
    //create user dictionary
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[engagement dictionaryRepresentation] forKey:@"engagement"];
    
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"activities/%d/engagements", [engagement.activityId intValue]]];
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

- (DDRequestId)getMessagesForEngagement:(DDEngagement*)engagement
{
    //create request
    NSString *requestPath = [[DDTools apiUrlPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"activities/%d/engagements/%d/messages", [engagement.activityId intValue], [engagement.identifier intValue]]];
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
        else if (userData.method == DDAPIControllerMethodTypeUpdatePhotoForMe)
        {
            //create photo object
            DDImage *photo = [DDImage objectWithDictionary:[[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body]];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:photo withObject:nil];
        }
        else if (userData.method == DDAPIControllerMethodTypeGetFriends)
        {
            //extract data
            NSMutableArray *users = [NSMutableArray array];
            NSArray *responseData = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
            for (NSDictionary *dic in responseData)
            {
                //create placemark
                DDShortUser *user = [DDShortUser objectWithDictionary:dic];
                if (user)
                    [users addObject:user];
            }
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:users withObject:nil];
        }
        else if (userData.method == DDAPIControllerMethodTypeGetFriendshipInvitations)
        {
            //extract data
            NSMutableArray *friendshipInvitations = [NSMutableArray array];
            NSArray *responseData = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
            for (NSDictionary *dic in responseData)
            {
                //create placemark
                DDFriendship *friendship = [DDFriendship objectWithDictionary:dic];
                if (friendship)
                    [friendshipInvitations addObject:friendship];
            }
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:friendshipInvitations withObject:nil];
        }
        else if (userData.method == DDAPIControllerMethodTypeRequestApproveFriendship)
        {
            //create friendship object
            DDFriendship *friendship = [DDImage objectWithDictionary:[[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body]];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:friendship withObject:nil];
        }
        else if (userData.method == DDAPIControllerMethodTypeRequestDenyFriendship ||
                 userData.method == DDAPIControllerMethodTypeRequestDeleteFriend ||
                 userData.method == DDAPIControllerMethodTypeRequestInvitations ||
                 userData.method == DDAPIControllerMethodTypeRequestDeleteDoubleDate)
        {
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:nil withObject:nil];
        }
        else if (userData.method == DDAPIControllerMethodTypeGetFacebookFriends)
        {
            //extract data
            NSMutableArray *facebookFriends = [NSMutableArray array];
            NSArray *responseData = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
            for (NSDictionary *dic in responseData)
            {
                //create placemark
                DDShortUser *facebookUser = [DDShortUser objectWithDictionary:dic];
                if (facebookUser)
                    [facebookFriends addObject:facebookUser];
            }
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:facebookFriends withObject:nil];
        }
        else if (userData.method == DDAPIControllerMethodTypeCreateDoubleDate)
        {
            //create object
            DDDoubleDate *doubleDate = [DDDoubleDate objectWithDictionary:[[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body]];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:doubleDate withObject:nil];
        }
        else if (userData.method == DDAPIControllerMethodTypeGetDoubleDates ||
                 userData.method == DDAPIControllerMethodTypeGetMyDoubleDates)
        {
            //extract data
            NSMutableArray *doubleDates = [NSMutableArray array];
            NSArray *responseData = [[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body];
            for (NSDictionary *dic in responseData)
            {
                //create placemark
                DDDoubleDate *doubleDate = [DDDoubleDate objectWithDictionary:dic];
                if (doubleDate)
                    [doubleDates addObject:doubleDate];
            }
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:doubleDates withObject:nil];
        }
        else if (userData.method == DDAPIControllerMethodTypeGetEngagements)
        {
        }
        else if (userData.method == DDAPIControllerMethodTypeCreateEngagement)
        {
            //create object
            DDEngagement *engagement = [DDEngagement objectWithDictionary:[[[[SBJsonParser alloc] init] autorelease] objectWithData:response.body]];
            
            //inform delegate
            if (userData.succeedSel && [self.delegate respondsToSelector:userData.succeedSel])
                [self.delegate performSelector:userData.succeedSel withObject:engagement withObject:nil];
        }
        else if (userData.method == DDAPIControllerMethodTypeGetMessages)
        {
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
        [self.delegate performSelector:userData.failedSel withObject:error withObject:nil];
    
    //clear request
    [self clearRequest:request];
}

- (void)requestDidCancelLoad:(RKRequest *)request
{
    //create error
    NSError *error = [NSError errorWithDomain:@"DDDomain" code:DDErrorTypeCancelled userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Cancelled", nil) forKey:NSLocalizedDescriptionKey]];
    
    //redirect to self
    [self request:request didFailLoadWithError:error];
    
    //clear request
    [self clearRequest:request];
}

- (void)requestDidTimeout:(RKRequest *)request
{
    //create error
    NSError *error = [NSError errorWithDomain:@"DDDomain" code:DDErrorTypeTimeout userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Timeout", nil) forKey:NSLocalizedDescriptionKey]];
    
    //redirect to self
    [self request:request didFailLoadWithError:error];
    
    //clear request
    [self clearRequest:request];
}


@end
