//
//  DDAlertView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAlertView.h"
#import "DDAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation DDAlertView
{
    UIView *fadeView_;
    UIView *bounceView_;
}

@synthesize bounceView=bounceView_;

- (CGFloat)showAnimationDuration
{
    return 0.3f;
}

- (CGFloat)hideAnimationDuration
{
    return 0.15f;
}

- (void)show
{
    //save window
    UIWindow *window = [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] window];
    
    //set size
    self.frame = CGRectMake(0, 0, window.bounds.size.width, window.bounds.size.height);
    
    //set center
    self.center = CGPointMake(window.bounds.size.width/2, window.bounds.size.height/2);
    
    //add view
    [window addSubview:self];
    
    //fade screen
    fadeView_ = [[UIView alloc] initWithFrame:[window bounds]];
    fadeView_.alpha = 0;
    fadeView_.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
    [self addSubview:fadeView_];
    
    //add bounce view
    bounceView_ = [[UIView alloc] initWithFrame:[window bounds]];
    [self addSubview:bounceView_];
    
    //start animation
    [self animationWillStart];
    
    //start animation
    [UIView animateWithDuration:[self showAnimationDuration] animations:^{
        
        //animate fade
        fadeView_.alpha = 1;
        
        //animate bounce
        CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        bounceAnimation.fillMode = kCAFillModeBoth;
        bounceAnimation.removedOnCompletion = YES;
        bounceAnimation.duration = [self showAnimationDuration];
        bounceAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 0.01f)],
                                   [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.1f)],
                                   [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 0.9f)],
                                   [NSValue valueWithCATransform3D:CATransform3DIdentity]];
        bounceAnimation.keyTimes = @[@0.0f, @0.5f, @0.75f, @1.0f];
        bounceAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [bounceView_.layer addAnimation:bounceAnimation forKey:nil];
        
        //animate show
        [self onAnimateShow];
    }];
}

- (void)onAnimateShow
{
}

- (void)dismiss
{
    //animate
    [UIView animateWithDuration:[self hideAnimationDuration] animations:^{

        //animate fade
        fadeView_.alpha = 0;
        
        //animate bounce
        CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        bounceAnimation.fillMode = kCAFillModeBoth;
        bounceAnimation.removedOnCompletion = NO;
        bounceAnimation.duration = [self hideAnimationDuration];
        bounceAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity],
                                   [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 0.9f)],
                                   [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7f, 0.7f, 0.7f)],
                                   [NSValue valueWithCATransform3D:CATransform3DMakeScale(0, 0, 0)]];
        bounceAnimation.keyTimes = @[@0.0f, @0.25f, @0.5f, @1.0f];
        bounceAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [bounceView_.layer addAnimation:bounceAnimation forKey:nil];
        
        //make callback
        [self onAnimateHide];
        
    } completion:^(BOOL finished) {
        
        //inform about the stop
        [self animationDidStop];
    }];
    
    //remove from superview after delay
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:[self hideAnimationDuration]];
}

- (void)onAnimateHide
{
    
}

- (void)animationWillStart
{
    
}

- (void)animationDidStop
{
    
}

- (void)dealloc
{
    [fadeView_ release];
    [bounceView_ release];
    [super dealloc];
}

@end
