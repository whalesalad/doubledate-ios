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
    UIView *viewNoData_;
    BOOL refreshControlEnabled_;
    UISearchBar *previousSearchBar_;
}

@property(nonatomic, assign) BOOL showsCancelButton;

@property(nonatomic, readonly) DDSearchBar *searchBar;
@property(nonatomic, readonly) NSString *searchTerm;

@property(nonatomic, readonly) UIView *viewNoData;

@property(nonatomic, retain) NSString *backButtonTitle;
@property(nonatomic, assign) BOOL moveWithKeyboard;

@property(nonatomic, assign) BOOL shouldShowNavigationMenu;

@property(nonatomic, retain) NSDictionary *cellsIdentifiers;

- (void)setupSearchBar;

- (void)updateNoDataView;
- (void)updateNoDataPercentage;

@end
