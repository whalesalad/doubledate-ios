//
//  DDChooseWingView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
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

@property(nonatomic, retain) IBOutlet UIButton *buttonFullscreen;

@property(nonatomic, assign) id<DDChooseWingViewDelegate> delegate;

@property(nonatomic, retain) NSArray *excludedUsers;

- (void)start;

@end
