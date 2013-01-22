//
//  DDAPIController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDRequestsController.h"

@class DDUser;
@class DDImage;
@class DDShortUser;
@class DDDoubleDate;
@class DDDoubleDateFilter;
@class DDEngagement;
@class DDMessage;

typedef enum
{
    DDLocationSearchOptionsCities,
    DDLocationSearchOptionsVenues,
    DDLocationSearchOptionsBoth
} DDLocationSearchOptions;

typedef int DDRequestId;

@protocol DDAPIControllerDelegate <NSObject>

@optional

- (void)getMeDidSucceed:(DDUser*)me;
- (void)getMeDidFailedWithError:(NSError*)error;

- (void)getUserDidSucceed:(DDUser*)user;
- (void)getUserDidFailedWithError:(NSError*)error;

- (void)updateMeSucceed:(DDUser*)user;
- (void)updateMeDidFailedWithError:(NSError*)error;

- (void)updatePhotoForMeSucceed:(DDImage*)photo;
- (void)updatePhotoForMeDidFailedWithError:(NSError*)error;

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

- (void)getEngagementsForDoubleDateSucceed:(NSArray*)engagements;
- (void)getEngagementsForDoubleDateDidFailedWithError:(NSError*)error;

- (void)getEngagementForDoubleDateSucceed:(DDEngagement*)engagement;
- (void)getEngagementForDoubleDateDidFailedWithError:(NSError*)error;

- (void)createEngagementSucceed:(DDEngagement*)engagement;
- (void)createEngagementDidFailedWithError:(NSError*)error;

- (void)unlockEngagementSucceed:(DDEngagement*)engagement;
- (void)unlockEngagementDidFailedWithError:(NSError*)error;

- (void)getMessagesForEngagementSucceed:(NSArray*)messages;
- (void)getMessagesForEngagementDidFailedWithError:(NSError*)error;

- (void)createMessageSucceed:(DDMessage*)message;
- (void)createMessageDidFailedWithError:(NSError*)error;

@end

@interface DDAPIController : NSObject
{
    DDRequestsController *controller_;
}

@property(nonatomic, assign) id<DDAPIControllerDelegate> delegate;

- (BOOL)isRequestExist:(DDRequestId)requestId;
- (BOOL)cancelRequest:(DDRequestId)requestId;

- (DDRequestId)getMe;

- (DDRequestId)getUser:(DDUser*)user;

- (DDRequestId)updateMe:(DDUser*)user;

- (DDRequestId)updatePhotoForMe:(UIImage*)photo;

- (DDRequestId)createUser:(DDUser*)user;

- (DDRequestId)requestFacebookUserForToken:(NSString*)fbToken;

- (DDRequestId)searchPlacemarksForLatitude:(CGFloat)latitude longitude:(CGFloat)longitude;
- (DDRequestId)searchPlacemarksForLatitude:(CGFloat)latitude longitude:(CGFloat)longitude query:(NSString*)query;
- (DDRequestId)searchPlacemarksForLatitude:(CGFloat)latitude longitude:(CGFloat)longitude options:(DDLocationSearchOptions)options;
- (DDRequestId)searchPlacemarksForLatitude:(CGFloat)latitude longitude:(CGFloat)longitude query:(NSString*)query options:(DDLocationSearchOptions)options;

- (DDRequestId)requestAvailableInterests;

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

- (DDRequestId)getEngagementsForDoubleDate:(DDDoubleDate*)doubleDate;

- (DDRequestId)getEngagementForDoubleDate:(DDDoubleDate*)doubleDate;

- (DDRequestId)createEngagement:(DDEngagement*)engagement forDoubleDate:(DDDoubleDate*)doubleDate;

- (DDRequestId)unlockEngagement:(DDEngagement*)engagement forDoubleDate:(DDDoubleDate*)doubleDate;

- (DDRequestId)getMessagesForEngagement:(DDEngagement*)engagement forDoubleDate:(DDDoubleDate*)doubleDate;

- (DDRequestId)createMessage:(DDMessage*)message forEngagement:(DDEngagement*)engagement forDoubleDate:(DDDoubleDate*)doubleDate;

@end
