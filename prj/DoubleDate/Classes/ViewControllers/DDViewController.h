//
//  DDViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewController+Extensions.h"
#import "DDAPIController.h"

@interface DDViewController : UIViewController<DDAPIControllerDelegate>
{
    NSMutableArray *buffer_;
    DDAPIController *apiController_;
    MBProgressHUD *hud_;
}

@end
