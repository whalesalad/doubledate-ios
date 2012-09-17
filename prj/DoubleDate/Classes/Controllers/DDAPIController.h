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

@protocol DDAPIControllerDelegate <NSObject>

@optional

- (void)getMeDidSucceed:(DDUser*)me;
- (void)getMeDidFailedWithError:(NSError*)error;

- (void)createUserSucceed:(DDUser*)user;
- (void)createUserDidFailedWithError:(NSError*)error;

- (void)requestFacebookUserSucceed:(DDUser*)user;
- (void)requestFacebookDidFailedWithError:(NSError*)error;

- (void)searchPlacemarksSucceed:(NSArray*)placemarks;
- (void)searchPlacemarksDidFailedWithError:(NSError*)error;

- (void)requestAvailableInterestsSucceed:(NSArray*)interests;
- (void)requestAvailableInterestsDidFailedWithError:(NSError*)error;

@end

@interface DDAPIController : NSObject
{
    DDRequestsController *controller_;
}

@property(nonatomic, assign) id<DDAPIControllerDelegate> delegate;

- (void)getMe;

- (void)createUser:(DDUser*)user;

- (void)requestFacebookUserForToken:(NSString*)fbToken;

- (void)searchPlacemarksForLatitude:(CGFloat)latitude longitude:(CGFloat)longitude;

- (void)requestAvailableInterests;

@end
