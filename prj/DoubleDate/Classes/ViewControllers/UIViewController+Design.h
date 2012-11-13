//
//  UIViewController+Design.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Design)

- (void)customizeViewDidLoad;
- (void)customizeViewWillAppear;

- (void)finishRefresh;
- (void)onRefreshStarted;
- (void)onRefreshFinished;

@end
