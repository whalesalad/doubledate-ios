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

+ (id)barButtonItemWithTitle:(NSString*)title normalImage:(UIImage*)normalImage highlightedImage:(UIImage*)highlightedImage disabledImage:(UIImage*)disabledImage target:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:14];
    CGFloat width = [title sizeWithFont:button.titleLabel.font].width + 14;
    if (width < normalImage.size.height)
        width = normalImage.size.height;
    button.frame = CGRectMake(0, 0, width, normalImage.size.height);
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[[button titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5f] forState:UIControlStateDisabled];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    DDBarButtonItem *barButtonItem = [[[DDBarButtonItem alloc] initWithCustomView:button] autorelease];
    [button setBackgroundImage:[DDTools resizableImageFromImage:normalImage] forState:UIControlStateNormal];
    [barButtonItem setNormalImage:[DDTools imageFromView:button]];
    [button setBackgroundImage:[DDTools resizableImageFromImage:highlightedImage] forState:UIControlStateNormal];
    [barButtonItem setHighlightedImage:[DDTools imageFromView:button]];
    [button setBackgroundImage:[DDTools resizableImageFromImage:disabledImage] forState:UIControlStateNormal];
    [barButtonItem setDisabledImage:[DDTools imageFromView:button]];
    [button setBackgroundImage:[DDTools resizableImageFromImage:normalImage] forState:UIControlStateNormal];
    [button setBackgroundImage:[DDTools resizableImageFromImage:highlightedImage] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[DDTools resizableImageFromImage:disabledImage] forState:UIControlStateDisabled];
    return barButtonItem;
}

+ (id)barButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    return [self barButtonItemWithTitle:title normalImage:[UIImage imageNamed:@"nav-btn.png"] highlightedImage:[UIImage imageNamed:@"nav-btn-highlight.png"] disabledImage:[UIImage imageNamed:@"nav-btn.png"] target:target action:action];
}

+ (id)backBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    return [self barButtonItemWithTitle:title normalImage:[UIImage imageNamed:@"back-btn.png"] highlightedImage:[UIImage imageNamed:@"back-btn-highlight.png"] disabledImage:[UIImage imageNamed:@"back-btn.png"] target:target action:action];
}

+ (id)leftBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    return [self barButtonItemWithTitle:title normalImage:[UIImage imageNamed:@"dd-segmented-left-btn.png"] highlightedImage:[UIImage imageNamed:@"dd-segmented-left-btn-highlight.png"] disabledImage:[UIImage imageNamed:@"dd-segmented-left-btn-disabled.png"] target:target action:action];
}

+ (id)middleBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    return [self barButtonItemWithTitle:title normalImage:[UIImage imageNamed:@"dd-segmented-center-btn"] highlightedImage:[UIImage imageNamed:@"dd-segmented-center-btn-highlight.png"] disabledImage:[UIImage imageNamed:@"dd-segmented-center-btn-disabled.png"] target:target action:action];
}

+ (id)rightBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    return [self barButtonItemWithTitle:title normalImage:[UIImage imageNamed:@"dd-segmented-right-btn.png"] highlightedImage:[UIImage imageNamed:@"dd-segmented-right-btn-highlight.png"] disabledImage:[UIImage imageNamed:@"dd-segmented-right-btn-disabled.png"] target:target action:action];
}

- (void)dealloc
{
    [normalImage_ release];
    [highlightedImage_ release];
    [disabledImage_ release];
    [super dealloc];
}

@end
