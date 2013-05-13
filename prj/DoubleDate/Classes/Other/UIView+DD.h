//
//  UIView+DD.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDUser;

@interface UIView (Interests)

- (CGFloat)applyInterestsForUser:(DDUser*)user bubbleImage:(UIImage*)bubbleImage matchedBubbleImage:(UIImage*)matchedBubbleImage custmomizationHandler:(void (^)(UILabel *bubbleLabel))custmomizationHandler DEPRECATED_ATTRIBUTE;

@end

@interface UIView (Other)

- (void)applyNoDataWithImage:(UIImage*)image title:(NSString*)title addButtonTitle:(NSString*)title addButtonTarget:(id)target addButtonAction:(SEL)action addButtonEdgeInsets:(UIEdgeInsets)insets detailed:(NSString*)detailed DEPRECATED_ATTRIBUTE;

- (void)applyNoDataWithMainText:(NSString*)mainText infoText:(NSString*)infoText;

- (UIButton*)baseButtonWithImage:(UIImage*)image;

- (void)customizeGenericLabel:(UILabel*)label;

- (UIButton*)lowerButtonWithTitle:(NSString*)title backgroundImage:(UIImage*)background;
- (UIButton*)lowerGrayButtonWithTitle:(NSString*)title;
- (UIButton*)lowerBlueButtonWithTitle:(NSString*)title;

@end
