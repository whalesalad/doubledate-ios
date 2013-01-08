//
//  DDTabBarBackgroundView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 1/8/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDTabBarBackgroundView : UIView
{
    NSMutableArray *imageViews_;
}

@property(nonatomic, assign) NSInteger numberOfTabs;
@property(nonatomic, assign) NSInteger selectedTab;

@end
