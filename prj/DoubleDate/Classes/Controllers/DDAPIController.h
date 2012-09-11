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

@end

@interface DDAPIController : NSObject
{
    DDRequestsController *controller_;
}

@property(nonatomic, assign) id<DDAPIControllerDelegate> delegate;

- (void)getMe;

- (void)createUser:(DDUser*)user;

@end
