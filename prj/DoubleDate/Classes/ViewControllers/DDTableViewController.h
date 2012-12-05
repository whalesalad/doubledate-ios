//
//  DDTableViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewController+Extensions.h"
#import "DDAPIController.h"

@class DDAPIController;
@class DDSearchBar;

@interface DDTableViewController : UITableViewController<UISearchBarDelegate, DDAPIControllerDelegate>
{
    NSMutableArray *buffer_;
    DDAPIController *apiController_;
    MBProgressHUD *hud_;
    NSString *searchTerm_;
    BOOL movedWithKeyboard_;
}

@property(nonatomic, readonly) UISearchBar *searchBar;
@property(nonatomic, readonly) NSString *searchTerm;

@property(nonatomic, retain) NSString *backButtonTitle;
@property(nonatomic, assign) BOOL moveWithKeyboard;

- (void)setupSearchBar;

@end
