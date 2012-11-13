//
//  DDBarButtonItem.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDBarButtonItem.h"
#import "DDTools.h"

@implementation DDBarButtonItem

- (void)setButton:(UIButton*)button
{
    if (button_ != button)
    {
        [button_ release];
        button_ = [button retain];
    }
}

- (UIButton*)button
{
    return [[button_ retain] autorelease];
}

- (void)setNormalImage:(UIImage *)normalImage
{
    if (normalImage_ != normalImage)
    {
        [normalImage_ release];
        normalImage_ = [normalImage retain];
    }
}

- (UIImage*)normalImage
{
    return normalImage_;
}

- (void)setHighlightedImage:(UIImage *)highlightedImage
{
    if (highlightedImage_ != highlightedImage)
    {
        [highlightedImage_ release];
        highlightedImage_ = [highlightedImage retain];
    }
}

- (UIImage*)highlightedImage
{
    return highlightedImage_;
}

- (void)setDisabledImage:(UIImage *)disabledImage
{
    if (disabledImage_ != disabledImage)
    {
        [disabledImage_ release];
        disabledImage_ = [disabledImage retain];
    }
}

- (UIImage*)disabledImage
{
    return disabledImage_;
}

+ (id)barButtonItemWithTitle:(NSString*)title normalImage:(UIImage*)normalImage highlightedImage:(UIImage*)highlightedImage disabledImage:(UIImage*)disabledImage target:(id)target action:(SEL)action contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets titleImage:(UIImage*)titleImage
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    DD_F_BUTTON(button.titleLabel);
    CGFloat width = [title sizeWithFont:button.titleLabel.font].width + normalImage.size.width;
    if (width < normalImage.size.height)
        width = normalImage.size.height;
    button.frame = CGRectMake(0, 0, width, normalImage.size.height);
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:titleImage forState:UIControlStateNormal];
    [button setContentEdgeInsets:contentEdgeInsets];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    DDBarButtonItem *barButtonItem = [[[DDBarButtonItem alloc] initWithCustomView:button] autorelease];
    [barButtonItem setButton:button];
    [button setBackgroundImage:normalImage forState:UIControlStateNormal];
    [barButtonItem setNormalImage:[DDTools imageFromView:button]];
    [button setBackgroundImage:highlightedImage forState:UIControlStateNormal];
    [barButtonItem setHighlightedImage:[DDTools imageFromView:button]];
    [button setBackgroundImage:disabledImage forState:UIControlStateNormal];
    [barButtonItem setDisabledImage:[DDTools imageFromView:button]];
    [button setBackgroundImage:normalImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:disabledImage forState:UIControlStateDisabled];
    return barButtonItem;
}

+ (id)barButtonItemWithTitle:(NSString*)title normalImage:(UIImage*)normalImage highlightedImage:(UIImage*)highlightedImage disabledImage:(UIImage*)disabledImage target:(id)target action:(SEL)action contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets
{
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:contentEdgeInsets titleImage:nil];
}

+ (id)barButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    UIImage *normalImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"nav-btn.png"]];
    UIImage *highlightedImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"nav-btn-highlight.png"]];
    UIImage *disabledImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"nav-btn.png"]];
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsZero];
}

+ (id)barButtonItemWithImage:(UIImage*)image target:(id)target action:(SEL)action
{
    UIImage *normalImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"nav-btn.png"]];
    UIImage *highlightedImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"nav-btn-highlight.png"]];
    UIImage *disabledImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"nav-btn.png"]];
    return [self barButtonItemWithTitle:nil normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsZero titleImage:image];
}

+ (id)largeBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    UIImage *normalImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"large-button.png"]];
    UIImage *highlightedImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"large-button-highlight.png"]];
    UIImage *disabledImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"large-button.png"]];
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsZero];
}

+ (id)backBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    UIImage *normalImage = [[UIImage imageNamed:@"back-btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 14, 15, 7)];
    UIImage *highlightedImage = [[UIImage imageNamed:@"back-btn-highlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 14, 15, 7)];
    UIImage *disabledImage = [[UIImage imageNamed:@"back-btn.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 14, 15, 7)];
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
}

+ (id)leftBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    UIImage *normalImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"dd-segmented-left-btn.png"]];
    UIImage *highlightedImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"dd-segmented-left-btn-highlight.png"]];
    UIImage *disabledImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"dd-segmented-left-btn-disabled.png"]];
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsZero];
}

+ (id)leftLargeBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    UIImage *normalImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"large-segment-left.png"]];
    UIImage *highlightedImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"large-segment-left-selected.png"]];
    UIImage *disabledImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"large-segment-left.png"]];
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsMake(0, 14, 0, 0)];
}

+ (id)middleBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    UIImage *normalImage = [UIImage imageNamed:@"dd-segmented-center-btn.png"];
    UIImage *highlightedImage = [UIImage imageNamed:@"dd-segmented-center-btn-highlight.png"];
    UIImage *disabledImage = [UIImage imageNamed:@"dd-segmented-center-btn-disabled.png"];
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsZero];
}

+ (id)middleLargeBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    UIImage *normalImage = [UIImage imageNamed:@"large-segment-center.png"];
    UIImage *highlightedImage = [UIImage imageNamed:@"large-segment-center-selected.png"];
    UIImage *disabledImage = [UIImage imageNamed:@"large-segment-center.png"];
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsZero];
}

+ (id)rightBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    UIImage *normalImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"dd-segmented-right-btn.png"]];
    UIImage *highlightedImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"dd-segmented-right-btn-highlight.png"]];
    UIImage *disabledImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"dd-segmented-right-btn-disabled.png"]];
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsZero];
}

+ (id)rightLargeBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    UIImage *normalImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"large-segment-right.png"]];
    UIImage *highlightedImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"large-segment-right-selected.png"]];
    UIImage *disabledImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"large-segment-right.png"]];
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 14)];
}

- (void)dealloc
{
    [normalImage_ release];
    [highlightedImage_ release];
    [disabledImage_ release];
    [button_ release];
    [super dealloc];
}

@end
