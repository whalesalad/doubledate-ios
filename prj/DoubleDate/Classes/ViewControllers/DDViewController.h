//
//  DDViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewController+Extensions.h"
#import "DDAPIController.h"

@interface DDViewController : UIViewController<DDAPIControllerDelegate>
{
    NSMutableArray *buffer_;
    DDAPIController *apiController_;
    MBProgressHUD *hud_;
    BOOL movedWithKeyboard_;
}

@property(nonatomic, retain) NSString *backButtonTitle;
@property(nonatomic, assign) BOOL moveWithKeyboard;
@property(nonatomic, assign) BOOL shouldShowNavigationMenu;

@end
