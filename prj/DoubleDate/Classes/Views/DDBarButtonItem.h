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
}

- (UIImage*)normalImage;
- (UIImage*)highlightedImage;
- (UIImage*)disabledImage;

+ (id)barButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+ (id)backBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action;

+ (id)leftBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+ (id)middleBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+ (id)rightBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action;

@end
