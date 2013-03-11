//
//  DDChooseWingView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDAPIController;
@class DDDoubleDate;
@class DDShortUser;

@protocol DDChooseWingViewDelegate <NSObject>

- (void)chooseWingViewDidSelectUser:(DDShortUser*)user;

@end

@interface DDChooseWingView : UIView
{
    DDAPIController *apiController_;
    NSArray *friends_;
}

@property(nonatomic, assign) id<DDChooseWingViewDelegate> delegate;

- (void)start;

@end
