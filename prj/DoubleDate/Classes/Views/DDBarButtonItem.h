//
//  DDBarButtonItem.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDBarButtonItem : UIBarButtonItem
{
    UIImage *normalImage_;
    UIImage *highlightedImage_;
    UIImage *disabledImage_;
    UIButton *button_;
}

- (UIButton*)button;

- (UIImage*)normalImage;
- (UIImage*)highlightedImage;
- (UIImage*)disabledImage;

+ (id)barButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+ (id)barButtonItemWithImage:(UIImage*)image target:(id)target action:(SEL)action;
+ (id)largeBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+ (id)backBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action;

+ (id)leftBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+ (id)leftLargeBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+ (id)middleBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+ (id)middleLargeBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+ (id)rightBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+ (id)rightLargeBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action;

@end
