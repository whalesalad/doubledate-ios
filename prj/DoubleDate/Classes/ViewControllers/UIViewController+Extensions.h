//
//  UIViewController+Extensions.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;
@class DDAPIController;

@interface DDNavigationController : UINavigationController
{
    MBProgressHUD *hud_;
}
@end

@interface UIViewController (HUD)

@property(nonatomic, retain) MBProgressHUD *hud;

#define DECLARE_HUD_WITH_PROPERTY(_CLASS_, _P_)\
@implementation _CLASS_ (HUD)\
- (void)setHud:(MBProgressHUD *)v\
{\
    if (v != _P_)\
    {\
        [_P_ release];\
        _P_ = [v retain];\
    }\
}\
- (MBProgressHUD*)hud\
{\
    return _P_;\
}\
@end

- (void)showHudWithText:(NSString*)text animated:(BOOL)animated;
- (void)hideHud:(BOOL)animated;
- (BOOL)isHudExist;
- (UIView*)viewForHud;
- (void)showCompletedHudWithText:(NSString*)text;

@end

@interface UIViewController (API)

@property(nonatomic, retain) DDAPIController *apiController;

#define DECLARE_API_CONTROLLER_WITH_PROPERTY(_CLASS_, _P_)\
@implementation _CLASS_ (API)\
- (void)setApiController:(DDAPIController *)v\
{\
    if (v != _P_)\
    {\
        [_P_ release];\
        _P_ = [v retain];\
    }\
}\
- (DDAPIController*)apiController\
{\
    return _P_;\
}\
@end

@end

@interface UIViewController (Other)

@property(nonatomic, retain) NSMutableArray *buffer;

#define DECLARE_BUFFER_WITH_PROPERTY(_CLASS_, _P_)\
@implementation _CLASS_ (Other)\
- (void)setBuffer:(NSMutableArray *)v\
{\
    if (v != _P_)\
    {\
        [_P_ release];\
        _P_ = [v retain];\
    }\
}\
- (NSMutableArray*)buffer\
{\
    return _P_;\
}\
@end

- (UIViewController*)viewControllerForClass:(Class)vcClass;

- (UIView*)viewForHeaderWithMainText:(NSString*)mainText detailedText:(NSString*)detailedText;
- (UIView*)oldStyleViewForHeaderWithMainText:(NSString*)mainText detailedText:(NSString*)detailedText;
- (UIView*)viewForNavigationBarWithMainText:(NSString*)mainText detailedText:(NSString*)detailedText;

- (UILabel*)mainLabelForHeaderView:(UIView*)view;
- (UILabel*)detailedLabelForHeaderView:(UIView*)view;

- (void)dismissViewController;

@end
