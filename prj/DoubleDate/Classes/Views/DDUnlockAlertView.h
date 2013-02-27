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

- (void)unlockAlertViewDidCancel:(DDUnlockAlertView*)sender;
- (void)unlockAlertViewDidUnlock:(DDUnlockAlertView*)sender;

@end

@interface DDUnlockAlertView : UIView
{
}

@property(nonatomic, assign) id<DDUnlockAlertViewDelegate> delegate;

@property(nonatomic, assign) NSInteger price;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *message;

@end
