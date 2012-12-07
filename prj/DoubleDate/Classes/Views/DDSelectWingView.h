//
//  DDSelectWingView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDAPIController;
@class DDShortUser;
@class DDPhotoView;

@protocol DDSelectWingViewDelegate <NSObject>

- (void)selectWingViewDidSelectWing:(id)sender;

@end

@interface DDSelectWingView : UIView
{
    UIActivityIndicatorView *loading_;
    DDAPIController *apiController_;
    NSMutableArray *containers_;
}

@property(nonatomic, assign) id<DDSelectWingViewDelegate> delegate;

@property(nonatomic, readonly) DDShortUser *wing;

- (void)start;

@end