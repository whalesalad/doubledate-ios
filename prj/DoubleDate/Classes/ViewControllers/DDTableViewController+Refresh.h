//
//  DDTableViewController+Refresh.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewController.h"

@interface DDTableViewController (Refresh)

@property(nonatomic, assign) BOOL isRefreshControlEnabled;

- (void)startRefreshWithText:(NSString*)text;
- (void)onRefresh;
- (void)finishRefresh;

@end
