//
//  UIView+Other.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Other)

- (void)applyNoDataWithImage:(UIImage*)image title:(NSString*)title addButtonTitle:(NSString*)title addButtonTarget:(id)target addButtonAction:(SEL)action addButtonEdgeInsets:(UIEdgeInsets)insets detailed:(NSString*)detailed;

- (UIButton*)baseButtonWithImage:(UIImage*)image;

- (void)customizeGenericLabel:(UILabel*)label;

@end
