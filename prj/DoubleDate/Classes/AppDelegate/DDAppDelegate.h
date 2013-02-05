//
//  DDAppDelegate.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *viewController;

@property (retain, nonatomic) UIView *userPopover;

@property (retain, nonatomic) NSString *deviceToken;

@property (retain, nonatomic) UIView *navigationMenu;

@end
