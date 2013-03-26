//
//  DDDialogAlertView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDCustomizableAlertView.h"

@class DDDialogAlertView;
@class DDDialog;

@protocol DDDialogAlertViewDelegate <NSObject>

- (void)dialogAlertViewDidConfirm:(DDDialogAlertView*)alertView;
- (void)dialogAlertViewDidCancel:(DDDialogAlertView*)alertView;

@end

@interface DDDialogAlertView : DDCustomizableAlertView
{
    DDDialog *dialog_;
}

@property(nonatomic, assign) id<DDDialogAlertViewDelegate> dialogDelegate;

@property(nonatomic, retain) NSURL *imageUrl;

@property(nonatomic, readonly) DDDialog *dialog;

- (id)initWithDialog:(DDDialog*)dialog;

@end
