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
@class DDFriendship;
@class DDShortUser;
@class DDDoubleDate;

@protocol DDAPIControllerDelegate <NSObject>

@optional

- (void)getMeDidSucceed:(DDUser*)me;
- (void)getMeDidFailedWithError:(NSError*)error;

- (void)updateMeSucceed:(DDUser*)user;
- (void)updateMeDidFailedWithError:(NSError*)error;

- (void)updatePhotoForMeSucceed:(DDImage*)photo;
- (void)updatePhotoForMeDidFailedWithError:(NSError*)error;

- (void)createUserSucceed:(DDUser*)user;
- (void)createUserDidFailedWithError:(NSError*)error;

- (void)requestFacebookUserSucceed:(DDUser*)user;
- (void)requestFacebookDidFailedWithError:(NSError*)error;

- (void)searchPlacemarksSucceed:(NSArray*)placemarks;
- (void)searchPlacemarksDidFailedWithError:(NSError*)error;

- (void)requestAvailableInterestsSucceed:(NSArray*)interests;
- (void)requestAvailableInterestsDidFailedWithError:(NSError*)error;

- (void)getFriendsSucceed:(NSArray*)friends;
- (void)getFriendsDidFailedWithError:(NSError*)error;

- (void)getFriendshipInvitationsSucceed:(NSArray*)invitations;
- (void)getFriendshipInvitationsDidFailedWithError:(NSError*)error;

- (void)requestApproveFriendshipSucceed:(DDFriendship*)friendship;
- (void)requestApproveFriendshipDidFailedWithError:(NSError*)error;

- (void)requestDenyFriendshipSucceed;
- (void)requestDenyFriendshipDidFailedWithError:(NSError*)error;

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

- (void)requestDeleteDoubleDateSucceed;
- (void)requestDeleteDoubleDateDidFailedWithError:(NSError*)error;

@end

@interface DDAPIController : NSObject
{
    DDRequestsController *controller_;
}

@property(nonatomic, assign) id<DDAPIControllerDelegate> delegate;

- (void)getMe;

- (void)updateMe:(DDUser*)user;

- (void)updatePhotoForMe:(UIImage*)photo;

- (void)createUser:(DDUser*)user;

- (void)requestFacebookUserForToken:(NSString*)fbToken;

- (void)searchPlacemarksForLatitude:(CGFloat)latitude longitude:(CGFloat)longitude;

- (void)requestAvailableInterests;

- (void)getFriends;

- (void)getFriendshipInvitations;

- (void)requestApproveFriendship:(DDFriendship*)friendship;

- (void)requestDenyFriendship:(DDFriendship*)friendship;

- (void)requestDeleteFriend:(DDShortUser*)user;

- (void)getFriend:(DDShortUser*)user;

- (void)getFacebookFriends;

- (void)requestInvitationsForFBUsers:(NSArray*)fbIds andDDUsers:(NSArray*)ddIds;

- (void)createDoubleDate:(DDDoubleDate*)doubleDate;

- (void)getDoubleDates;

- (void)requestDeleteDoubleDate:(DDDoubleDate*)doubleDate;

@end
