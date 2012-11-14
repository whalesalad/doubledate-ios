//
//  DDButton.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDButtonDeprecated : UIButton
{
    UITextField *textField_;
    NSString *placeholder_;
    NSString *text_;
    UIView *normalIcon_;
    UIView *selectedIcon_;
    UIView *rightView_;
}

@property(nonatomic, retain) UIView *normalIcon;
@property(nonatomic, retain) UIView *selectedIcon;
@property(nonatomic, retain) UIView *rightView;
@property(nonatomic, retain) UIFont *font;
@property(nonatomic, retain) NSString *placeholder;
@property(nonatomic, retain) NSString *text;

@end
