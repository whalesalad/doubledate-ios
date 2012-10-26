//
//  DDButton.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDButton.h"

@implementation DDButton

- (void)initSelf
{
    //add text field
    [textField_ removeFromSuperview];
    [textField_ release];
    textField_ = [[UITextField alloc] init];
    textField_.userInteractionEnabled = NO;
    textField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self addSubview:textField_];
    
    //add press handler
    [self removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
    [self addTarget:self action:@selector(onSelected) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(onSelected) forControlEvents:UIControlEventTouchDragEnter];
    [self addTarget:self action:@selector(onUnselected) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(onUnselected) forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(onUnselected) forControlEvents:UIControlEventTouchCancel];
     [self addTarget:self action:@selector(onUnselected) forControlEvents:UIControlEventTouchDragExit];
}

- (void)onSelected
{
    if (self.selectedIcon)
        [self setLeftView:self.selectedIcon];
}

- (void)onUnselected
{
    [self setLeftView:self.normalIcon];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initSelf];
        self.frame = self.frame;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self initSelf];
        self.frame = self.frame;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    textField_.frame = CGRectMake(10, 0, self.frame.size.width-20, self.frame.size.height);
}

- (NSString*)prefix
{
    if (textField_.leftViewMode == UITextFieldViewModeAlways)
        return @" ";
    return @"";
}

- (void)setPlaceholder:(NSString *)v
{
    //set placehodler
    if (placeholder_ != v)
    {
        [placeholder_ release];
        placeholder_ = [v retain];
    }
    
    //update text
    if (placeholder_)
        textField_.placeholder = [NSString stringWithFormat:@"%@%@", [self prefix], placeholder_];
    else
        textField_.placeholder = nil;
}

- (NSString*)placeholder
{
    return placeholder_;
}

- (void)setText:(NSString *)v
{
    //set placehodler
    if (text_ != v)
    {
        [text_ release];
        text_ = [v retain];
    }
    
    //update text
    if (text_)
        textField_.text = [NSString stringWithFormat:@"%@%@", [self prefix], text_];
    else
        textField_.text = nil;
}

- (NSString*)text
{
    return text_;
}

- (void)setFont:(UIFont *)font
{
    textField_.font = font;
}

- (UIFont*)font
{
    return textField_.font;
}

- (void)setNormalIcon:(UIView *)normalIcon
{
    //update icon
    if (normalIcon_ != normalIcon)
    {
        [normalIcon_ release];
        normalIcon_ = [normalIcon retain];
    }
    
    //update text field
    textField_.leftView = normalIcon;
    if (normalIcon)
        textField_.leftViewMode = UITextFieldViewModeAlways;
    else
        textField_.leftViewMode = UITextFieldViewModeNever;
    [self setText:self.text];
    [self setPlaceholder:self.placeholder];
}

- (UIView*)normalIcon
{
    return normalIcon_;
}

- (void)setSelectedIcon:(UIView *)selectedIcon
{
    //update icon
    if (selectedIcon_ != selectedIcon)
    {
        [selectedIcon_ release];
        selectedIcon_ = [selectedIcon retain];
    }
}

- (UIView*)selectedIcon
{
    return selectedIcon_;
}

- (void)setLeftView:(UIView *)leftView
{
    textField_.leftView = leftView;
    if (leftView)
        textField_.leftViewMode = UITextFieldViewModeAlways;
    else
        textField_.leftViewMode = UITextFieldViewModeNever;
    [self setText:self.text];
    [self setPlaceholder:self.placeholder];
}

- (void)dealloc
{
    [textField_ release];
    [normalIcon_ release];
    [selectedIcon_ release];
    [super dealloc];
}

@end
