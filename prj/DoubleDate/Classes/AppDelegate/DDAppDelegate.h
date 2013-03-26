//
//  DDAppDelegate.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDAPIController.h"

extern NSString *DDAppDelegateApplicationBadgeNumberUpdatedNotification;

@class DDAPNSPayload;
@protocol DDChooseWingViewDelegate;

@interface DDAppDelegate : UIResponder <UIApplicationDelegate, DDAPIControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *viewController;

@property (strong, nonatomic) UINavigationController *topNavigationController;

@property (retain, nonatomic) UIView *userPopover;

@property (retain, nonatomic) NSString *deviceToken;

@property (retain, nonatomic) UIView *navigationMenu;

@property (assign, nonatomic) BOOL navigationMenuExist;

@property (retain, nonatomic) UIView *wingsMenu;

@property (assign, nonatomic) BOOL wingsMenuExist;

@property (assign, nonatomic) id<DDChooseWingViewDelegate> wingsMenuDelegate;

@property (retain, nonatomic) DDAPIController *apiController;

@property (retain, nonatomic) DDEngagement *selectedEngagement;

@property (retain, nonatomic) DDAPNSPayload *payload;

@property (retain, nonatomic) DDAPNSPayload *openedPayload;

@property (retain, nonatomic) NSArray *products;

- (void)updateApplicationBadge;

@end
