//
//  DDViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;

@interface DDViewController : UIViewController
{
    NSMutableArray *buffer_;
}

@property(nonatomic, retain) UIView *viewAfterAppearing;

- (void)showHudWithText:(NSString*)text animated:(BOOL)animated;
- (void)hideHud:(BOOL)animated;
- (BOOL)isHudExist;
- (UIView*)viewForHud;

- (UIViewController*)viewControllerForClass:(Class)vcClass;

@end
