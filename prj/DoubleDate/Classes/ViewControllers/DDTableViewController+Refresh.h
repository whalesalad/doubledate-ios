//
//  DDTableViewController+Refresh.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTableViewController.h"

@interface DDTableViewController (Refresh)

@property(nonatomic, assign) BOOL isRefreshControlEnabled;

- (void)onChangedSearchTerm;
- (void)startRefreshWithText:(NSString*)text;
- (void)onRefresh;
- (void)finishRefresh;

@end
