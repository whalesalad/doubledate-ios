//
//  DDAppDelegate.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDAPIController.h"

@interface DDAppDelegate : UIResponder <UIApplicationDelegate, DDAPIControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *viewController;

@property (strong, nonatomic) UINavigationController *topNavigationController;

@property (retain, nonatomic) UIView *userPopover;

@property (retain, nonatomic) NSString *deviceToken;

@property (retain, nonatomic) UIView *navigationMenu;

@property (assign, nonatomic) BOOL navigationMenuExist;

@property (retain, nonatomic) DDAPIController *apiController;

@property (retain, nonatomic) DDEngagement *selectedEngagement;

@property (retain, nonatomic) NSString *callbackUrl;

@property (retain, nonatomic) NSString *openedCallbackUrl;

@end
