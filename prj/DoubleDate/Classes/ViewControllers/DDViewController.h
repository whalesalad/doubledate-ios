//
//  DDViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;
@class DDAPIController;

@interface DDViewController : UIViewController
{
    NSMutableArray *buffer_;
    DDAPIController *apiController_;
    MBProgressHUD *hud_;
}

@property(nonatomic, readonly) DDAPIController *apiController;
@property(nonatomic, retain) UIView *viewAfterAppearing;

- (void)showHudWithText:(NSString*)text animated:(BOOL)animated;
- (void)hideHud:(BOOL)animated;
- (BOOL)isHudExist;
- (UIView*)viewForHud;
- (void)showCompletedHudWithText:(NSString*)text;

- (UIViewController*)viewControllerForClass:(Class)vcClass;

- (UIView*)viewForHeaderWithMainText:(NSString*)mainText detailedText:(NSString*)detailedText;

@end
