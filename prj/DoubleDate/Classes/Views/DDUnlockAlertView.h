//
//  DDUnlockAlertView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDUnlockAlertView;

@protocol DDUnlockAlertViewDelegate <NSObject>

@optional

- (void)unlockAlertViewDidCancel:(DDUnlockAlertView*)sender;
- (void)unlockAlertViewDidUnlock:(DDUnlockAlertView*)sender;

@end

@interface DDUnlockAlertView : UIView
{
}

@property(nonatomic, assign) id<DDUnlockAlertViewDelegate> delegate;

@property(nonatomic, retain) NSString *cancelButtonText;
@property(nonatomic, retain) NSString *unlockButtonText;

@property(nonatomic, assign) NSInteger price;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *message;

- (void)show;
- (void)dismiss;

@end

@interface DDUnlockAlertViewFullScreen : DDUnlockAlertView

@end