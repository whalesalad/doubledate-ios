//
//  DDAlertView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDAlertView : UIView
{
}

@property(nonatomic, readonly) UIView *bounceView;

- (void)show;
- (void)dismiss;

- (void)animationWillStart;
- (void)animationDidStop;

- (void)onAnimateShow;
- (void)onAnimateHide;

@end
