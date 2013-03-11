//
//  DDAppDelegate+WingsMenu.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAppDelegate+WingsMenu.h"
#import <QuartzCore/QuartzCore.h>

#define kTagWingsMenuDim 1
#define kTagWingsMenuView 2

@implementation DDAppDelegate (WingsMenu)

- (void)presentWingsMenuWithDelegate:(id<DDChooseWingViewDelegate>)delegate
{
    //save delegate
    self.wingsMenuDelegate = delegate;
    
    //check if already exist
    if (self.wingsMenuExist)
        return;
        
    //set flag
    self.wingsMenuExist = YES;
    
    //create wings menu
    [self.wingsMenu removeFromSuperview];
    self.wingsMenu = [[[UIView alloc] initWithFrame:CGRectMake(0, 20, self.window.frame.size.width, self.window.frame.size.height-20)] autorelease];
    self.wingsMenu.backgroundColor = [UIColor clearColor];
    self.wingsMenu.clipsToBounds = YES;
    [self.window addSubview:self.wingsMenu];
    
    //add dim
    UIView *dim = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.wingsMenu.frame.size.width, self.wingsMenu.frame.size.height)] autorelease];
    dim.tag = kTagWingsMenuDim;
    dim.backgroundColor = [UIColor blackColor];
    dim.alpha = 0;
    [self.wingsMenu addSubview:dim];
    
    //add button under table view
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, dim.frame.size.width, dim.frame.size.height);
    [button addTarget:self action:@selector(dismissWingsMenu) forControlEvents:UIControlEventTouchUpInside];
    [dim addSubview:button];
    
    //add table view
    DDChooseWingView *wings = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DDChooseWingView class]) owner:self options:nil] objectAtIndex:0];
    wings.delegate = self;
    wings.tag = kTagWingsMenuView;
    wings.frame = CGRectMake(self.wingsMenu.frame.size.width, 0, wings.frame.size.width, self.wingsMenu.frame.size.height);
    [wings start];
    [self.wingsMenu addSubview:wings];
    wings.layer.cornerRadius = 6;
    
    //animate
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        UIView *viewDim = [self.wingsMenu viewWithTag:kTagWingsMenuDim];
        [viewDim setAlpha:0.5f];
        UIView *viewWings = [self.wingsMenu viewWithTag:kTagWingsMenuView];
        viewWings.center = CGPointMake(viewWings.center.x-viewWings.frame.size.width+viewWings.layer.cornerRadius, viewWings.center.y);
    } completion:^(BOOL finished) {
    }];
}

- (void)dismissWingsMenu
{
    //check if not exist
    if (!self.wingsMenuExist)
        return;
    
    //unset flag
    self.wingsMenuExist = NO;
    
    //animate
    UIView *viewDim = [self.wingsMenu viewWithTag:kTagWingsMenuDim];
    UIView *viewWings = [self.wingsMenu viewWithTag:kTagWingsMenuView];
    [UIView animateWithDuration:0.1f animations:^{
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [viewDim setAlpha:0];
            viewWings.center = CGPointMake(viewWings.center.x+viewWings.frame.size.width-viewWings.layer.cornerRadius, viewWings.center.y);
        } completion:^(BOOL finished) {
            [self.wingsMenu removeFromSuperview];
            self.wingsMenu = nil;
        }];
    }];
}

- (BOOL)isWingsMenuExist
{
    return self.wingsMenuExist;
}

#pragma mark -
#pragma mark DDChooseWingViewDelegate

- (void)chooseWingViewDidSelectUser:(DDShortUser*)user
{
    //redirect to delegate
    [self.wingsMenuDelegate chooseWingViewDidSelectUser:user];
    
    //unset delegate
    self.wingsMenuDelegate = nil;
    
    //hide wings menu
    [self dismissWingsMenu];
}

@end
