//
//  DDTabBarBackgroundView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 1/8/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

__attribute__ ((deprecated))
@interface DDTabBarBackgroundView : UIView
{
    NSMutableArray *imageViews_;
}

@property(nonatomic, assign) NSInteger numberOfTabs;
@property(nonatomic, assign) NSInteger selectedTab;

- (void)setFinishedSelectedImage:(UIImage *)selectedImage withFinishedUnselectedImage:(UIImage *)unselectedImage forTab:(NSInteger)tab;

@end
