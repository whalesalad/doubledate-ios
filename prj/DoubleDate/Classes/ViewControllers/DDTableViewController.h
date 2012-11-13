//
//  DDTableViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewController+Extensions.h"

@class DDAPIController;

@interface DDTableViewController : UITableViewController
{
    NSMutableArray *buffer_;
    DDAPIController *apiController_;
    MBProgressHUD *hud_;
}

@end
