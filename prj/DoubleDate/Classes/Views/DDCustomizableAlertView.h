//
//  DDCustomizableAlertView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAlertView.h"

@class DDCustomizableAlertView;

@protocol DDCustomizableAlertViewDelegate <NSObject>

- (NSInteger)heightForCustomAreaOfAlert:(DDCustomizableAlertView*)alert;
- (UIView*)viewForCustomAreaOfAlert:(DDCustomizableAlertView*)alert;

- (NSInteger)heightForButtonsAreaOfAlert:(DDCustomizableAlertView*)alert;
- (NSInteger)numberOfButtonsOfAlert:(DDCustomizableAlertView*)alert;
- (UIButton*)buttonWithIndex:(NSInteger)index ofAlert:(DDCustomizableAlertView*)alert;

@end

@interface DDCustomizableAlertView : DDAlertView
{
}

@property(nonatomic, assign) id<DDCustomizableAlertViewDelegate> delegate;

@property(nonatomic, retain) NSString *message;
@property(nonatomic, retain) NSString *title;

@property(nonatomic, assign) NSInteger coins;

@end
