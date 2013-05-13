//
//  DDButton.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDButton.h"
#import "UIImage+DD.h"
#import <QuartzCore/QuartzCore.h>

@implementation DDButtonDeprecated

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
    if (rightView_)
    {
        rightView_.center = CGPointMake(self.frame.size.width-rightView_.frame.size.width-5+rightView_.frame.size.width/2, self.frame.size.height/2);
        textField_.frame = CGRectMake(textField_.frame.origin.x, textField_.frame.origin.y, textField_.frame.size.width - rightView_.frame.size.width, textField_.frame.size.height);
    }
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

- (UIView*)leftView
{
    return textField_.leftView;
}

- (void)setRightView:(UIView *)rightView
{
    if (rightView != rightView_)
    {
        [rightView_ removeFromSuperview];
        [rightView_ release];
        rightView_ = [rightView retain];
        [self addSubview:rightView_];
        [self setNeedsLayout];
    }
}

- (UIView*)rightView
{
    return rightView_;
}

- (void)dealloc
{
    [textField_ release];
    [normalIcon_ release];
    [selectedIcon_ release];
    [rightView_ release];
    [super dealloc];
}

@end

@implementation DDToggleButton

@synthesize toggled;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self addTarget:self action:@selector(touched) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    [super setBackgroundImage:image forState:state];
    if (state == UIControlStateNormal)
    {
        [normalImage_ release];
        normalImage_ = [image retain];
    }
    if (state == UIControlStateHighlighted)
    {
        [highlightedImage_ release];
        highlightedImage_ = [image retain];
    }
}

- (UIImage*)backgroundImageForState:(UIControlState)state
{
    if (state == UIControlStateNormal)
        return normalImage_;
    if (state == UIControlStateHighlighted)
        return highlightedImage_;
    return [super imageForState:state];
}

- (void)touched
{
    self.toggled = !self.toggled;
}

- (void)setToggled:(BOOL)v
{
    toggled = v;
    if (toggled)
        [super setBackgroundImage:highlightedImage_ forState:UIControlStateNormal];
    else
        [super setBackgroundImage:normalImage_ forState:UIControlStateNormal];
}

- (void)dealloc
{
    [normalImage_ release];
    [highlightedImage_ release];
    [super dealloc];
}

@end

@implementation UIButton (DD)

- (void)applyBottomBarDesignWithTitle:(NSString*)title icon:(UIImage*)icon background:(UIImage*)background
{
    [self setBackgroundImage:[background resizableImage] forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5f] forState:UIControlStateDisabled];

    [self.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16]];
    
    self.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.titleLabel.layer.shadowRadius = 0;
    self.titleLabel.layer.shadowOpacity = 0.4f;
    self.titleLabel.layer.shadowOffset = CGSizeMake(0, -1);
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (icon)
    {
        UIImageView *iconImageView = [[[UIImageView alloc] initWithImage:icon] autorelease];
        iconImageView.center = CGPointMake(self.frame.size.width/2 - self.titleLabel.frame.size.width/2-4, self.frame.size.height/2);
        [self addSubview:iconImageView];
        self.titleEdgeInsets = UIEdgeInsetsMake(2, iconImageView.frame.size.width+6, 0, 0);
    }
}

@end
