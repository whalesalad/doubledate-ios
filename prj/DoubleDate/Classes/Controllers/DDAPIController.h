//
//  DDAPIController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "DDRequestsController.h"

@class DDUser;
@class DDImage;
@class DDShortUser;
@class DDDoubleDate;
@class DDDoubleDateFilter;
@class DDEngagement;
@class DDMessage;
@class DDNotification;
@class DDMaxActivitiesPayload;

typedef enum
{
    DDLocationSearchOptionsCities,
    DDLocationSearchOptionsVenues,
    DDLocationSearchOptionsBoth
} DDLocationSearchOptions;

typedef enum
{
    DDAPIControllerMethodTypeGetMe,
    DDAPIControllerMethodTypeGetUser,
    DDAPIControllerMethodTypeUpdateMe,
    DDAPIControllerMethodTypeUpdatePhotoForMe,
    DDAPIControllerMethodTypeUpdatePhotoForMeFromFacebook,
    DDAPIControllerMethodTypeCreateUser,
    DDAPIControllerMethodTypeRequestFBUser,
    DDAPIControllerMethodTypeSearchPlacemarks,
    DDAPIControllerMethodTypeRequestAvailableInterests,
    DDAPIControllerMethodTypeGetFriends,
    DDAPIControllerMethodTypeRequestApproveFriendshipForFriend,
    DDAPIControllerMethodTypeRequestDenyFriendshipForFriend,
    DDAPIControllerMethodTypeRequestDeleteFriend,
    DDAPIControllerMethodTypeGetFriend,
    DDAPIControllerMethodTypeGetFacebookFriends,
    DDAPIControllerMethodTypeRequestInvitations,
    DDAPIControllerMethodTypeCreateDoubleDate,
    DDAPIControllerMethodTypeGetDoubleDates,
    DDAPIControllerMethodTypeGetMyDoubleDates,
    DDAPIControllerMethodTypeGetDoubleDate,
    DDAPIControllerMethodTypeRequestDeleteDoubleDate,
    DDAPIControllerMethodTypeGetEngagements,
    DDAPIControllerMethodTypeGetEngagement,
    DDAPIControllerMethodTypeCreateEngagement,
    DDAPIControllerMethodTypeUnlockEngagement,
    DDAPIControllerMethodTypeGetMessages,
    DDAPIControllerMethodTypeCreateMessage,
    DDAPIControllerMethodTypeGetNotifications,
    DDAPIControllerMethodTypeGetNotification,
    DDAPIControllerMethodTypeUpdateNotification,
    DDAPIControllerMethodTypeGetMeUnlockMaxActivities,
    DDAPIControllerMethodTypeUnlockMeMaxActivities,
    DDAPIControllerMethodTypeGetInAppProducts,
} DDAPIControllerMethodType;

typedef int DDRequestId;

@protocol DDAPIControllerDelegate <NSObject>

@optional

- (void)requestDidSucceed:(NSObject*)object;
- (void)requestDidFailedWithError:(NSError*)error;

- (void)getMeDidSucceed:(DDUser*)me;
- (void)getMeDidFailedWithError:(NSError*)error;

- (void)getUserDidSucceed:(DDUser*)user;
- (void)getUserDidFailedWithError:(NSError*)error;

- (void)updateMeSucceed:(DDUser*)user;
- (void)updateMeDidFailedWithError:(NSError*)error;

- (void)updatePhotoForMeSucceed:(DDImage*)photo;
- (void)updatePhotoForMeDidFailedWithError:(NSError*)error;

- (void)updatePhotoForMeFromFacebookSucceed:(DDImage*)photo;
- (void)updatePhotoForMeFromFacebookDidFailedWithError:(NSError*)error;

- (void)createUserSucceed:(DDUser*)user;
- (void)createUserDidFailedWithError:(NSError*)error;

- (void)requestFacebookUserSucceed:(DDUser*)user;
- (void)requestFacebookDidFailedWithError:(NSError*)error;

- (void)searchPlacemarksSucceed:(NSArray*)placemarks forQuery:(NSString*)query;
- (void)searchPlacemarksDidFailedWithError:(NSError*)error;

- (void)requestAvailableInterestsSucceed:(NSArray*)interests;
- (void)requestAvailableInterestsDidFailedWithError:(NSError*)error;

- (void)getFriendsSucceed:(NSArray*)friends;
- (void)getFriendsDidFailedWithError:(NSError*)error;

- (void)requestApproveFriendshipForFriendSucceed:(DDShortUser*)friend;
- (void)requestApproveFriendshipForFriendDidFailedWithError:(NSError*)error;

- (void)requestDenyFriendshipForFriendSucceed;
- (void)requestDenyFriendshipForFriendDidFailedWithError:(NSError*)error;

- (void)requestDeleteFriendSucceed;
- (void)requestDeleteFriendDidFailedWithError:(NSError*)error;

- (void)getFriendSucceed:(DDUser*)user;
- (void)getFriendDidFailedWithError:(NSError*)error;

- (void)getFacebookFriendsSucceed:(NSArray*)friends;
- (void)getFacebookFriendsDidFailedWithError:(NSError*)error;

- (void)requestInvitationsSucceed:(NSArray*)friends;
- (void)requestInvitationsDidFailedWithError:(NSError*)error;

- (void)createDoubleDateSucceed:(DDDoubleDate*)doubleDate;
- (void)createDoubleDateDidFailedWithError:(NSError*)error;

- (void)getDoubleDatesSucceed:(NSArray*)doubleDates;
- (void)getDoubleDatesDidFailedWithError:(NSError*)error;

- (void)getDoubleMyDatesSucceed:(NSArray*)doubleDates;
- (void)getDoubleMyDatesDidFailedWithError:(NSError*)error;

- (void)getDoubleDateSucceed:(DDDoubleDate*)doubleDate;
- (void)getDoubleDateDidFailedWithError:(NSError*)error;

- (void)requestDeleteDoubleDateSucceed;
- (void)requestDeleteDoubleDateDidFailedWithError:(NSError*)error;

- (void)getEngagementsDateSucceed:(NSArray*)engagements;
- (void)getEngagementsDateDidFailedWithError:(NSError*)error;

- (void)getEngagementSucceed:(DDEngagement*)engagement;
- (void)getEngagementDidFailedWithError:(NSError*)error;

- (void)createEngagementSucceed:(DDEngagement*)engagement;
- (void)createEngagementDidFailedWithError:(NSError*)error;

- (void)unlockEngagementSucceed:(DDEngagement*)engagement;
- (void)unlockEngagementDidFailedWithError:(NSError*)error;

- (void)getMessagesForEngagementSucceed:(NSArray*)messages;
- (void)getMessagesForEngagementDidFailedWithError:(NSError*)error;

- (void)createMessageSucceed:(DDMessage*)message;
- (void)createMessageDidFailedWithError:(NSError*)error;

- (void)getNotificationsSucceed:(NSArray*)notifications;
- (void)getNotificationsDidFailedWithError:(NSError*)error;

- (void)getNotificationSucceed:(DDNotification*)notification;
- (void)getNotificationDidFailedWithError:(NSError*)error;

- (void)updateNotificationSucceed:(DDNotification*)notification;
- (void)updateNotificationDidFailedWithError:(NSError*)error;

- (void)getMeUnlockMaxActivitiesSucceed:(DDMaxActivitiesPayload*)payload;
- (void)getMeUnlockMaxActivitiesDidFailedWithError:(NSError*)error;

- (void)unlockMeMaxActivitiesSucceed:(DDMaxActivitiesPayload*)payload;
- (void)unlockMeMaxActivitiesDidFailedWithError:(NSError*)error;

- (void)getInAppProductsSucceed:(NSArray*)products;
- (void)getInAppProductsDidFailedWithError:(NSError*)error;

@end

@interface DDAPIController : NSObject
{
    DDRequestsController *controller_;
}

@property(nonatomic, assign) id<DDAPIControllerDelegate> delegate;

- (BOOL)isRequestExist:(DDRequestId)requestId;
- (BOOL)cancelRequest:(DDRequestId)requestId;
- (NSString*)pathForRequest:(DDRequestId)requestId;

- (DDRequestId)requestForPath:(NSString*)urlPath withMethod:(RKRequestMethod)method ofType:(DDAPIControllerMethodType)type;

- (DDRequestId)getMe;

- (DDRequestId)getUser:(DDUser*)user;

- (DDRequestId)updateMe:(DDUser*)user;

- (DDRequestId)updatePhotoForMe:(UIImage*)photo;

- (DDRequestId)updatePhotoForMeFromFacebook;

- (DDRequestId)createUser:(DDUser*)user;

- (DDRequestId)requestFacebookUserForToken:(NSString*)fbToken;

- (DDRequestId)searchPlacemarksForLatitude:(CGFloat)latitude longitude:(CGFloat)longitude;
- (DDRequestId)searchPlacemarksForLatitude:(CGFloat)latitude longitude:(CGFloat)longitude query:(NSString*)query;
- (DDRequestId)searchPlacemarksForLatitude:(CGFloat)latitude longitude:(CGFloat)longitude options:(DDLocationSearchOptions)options;
- (DDRequestId)searchPlacemarksForLatitude:(CGFloat)latitude longitude:(CGFloat)longitude query:(NSString*)query options:(DDLocationSearchOptions)options;

- (DDRequestId)requestAvailableInterests;
- (DDRequestId)requestAvailableInterestsWithQuery:(NSString*)query;

- (DDRequestId)getFriends;

- (DDRequestId)requestApproveFriendshipForFriend:(DDShortUser*)friendship;

- (DDRequestId)requestDenyFriendshipForFriend:(DDShortUser*)friendship;

- (DDRequestId)requestDeleteFriend:(DDShortUser*)user;

- (DDRequestId)getFriend:(DDShortUser*)user;

- (DDRequestId)getFacebookFriends;

- (DDRequestId)requestInvitationsForFBUsers:(NSArray*)fbIds andDDUsers:(NSArray*)ddIds;

- (DDRequestId)createDoubleDate:(DDDoubleDate*)doubleDate;

- (DDRequestId)getDoubleDatesWithFilter:(DDDoubleDateFilter*)filter;

- (DDRequestId)getMyDoubleDates;

- (DDRequestId)getDoubleDate:(DDDoubleDate*)doubleDate;

- (DDRequestId)requestDeleteDoubleDate:(DDDoubleDate*)doubleDate;

- (DDRequestId)getEngagements;

- (DDRequestId)getEngagement:(DDEngagement*)engagement;

- (DDRequestId)createEngagement:(DDEngagement*)engagement;

- (DDRequestId)unlockEngagement:(DDEngagement*)engagement;

- (DDRequestId)getMessagesForEngagement:(DDEngagement*)engagement;

- (DDRequestId)createMessage:(DDMessage*)message forEngagement:(DDEngagement*)engagement;

- (DDRequestId)getNotifications;

- (DDRequestId)getNotification:(DDNotification*)notification;

- (DDRequestId)updateNotification:(DDNotification*)notification;

- (DDRequestId)getMeUnlockMaxActivities;

- (DDRequestId)unlockMeMaxActivities:(DDMaxActivitiesPayload*)payload;

- (DDRequestId)getInAppProducts;

@end
