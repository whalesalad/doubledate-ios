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

+ (id)barButtonItemWithTitle:(NSString*)title normalImage:(UIImage*)normalImage highlightedImage:(UIImage*)highlightedImage disabledImage:(UIImage*)disabledImage target:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:14];
    [button setBackgroundImage:[DDTools resizableImageFromImage:normalImage] forState:UIControlStateNormal];
    [button setBackgroundImage:[DDTools resizableImageFromImage:highlightedImage] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[DDTools resizableImageFromImage:disabledImage] forState:UIControlStateDisabled];
    CGFloat width = [title sizeWithFont:button.titleLabel.font].width + 14;
    if (width < normalImage.size.width)
        width = normalImage.size.width;
    button.frame = CGRectMake(0, 0, width, normalImage.size.height);
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[[button titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5f] forState:UIControlStateDisabled];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[[DDBarButtonItem alloc] initWithCustomView:button] autorelease];
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
    return [self barButtonItemWithTitle:title normalImage:[UIImage imageNamed:@"segment-btn-left.png"] highlightedImage:[UIImage imageNamed:@"segment-btn-left-highlight.png"] disabledImage:[UIImage imageNamed:@"segment-btn-left-disabled.png"] target:target action:action];
}

+ (id)middleBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    return [self barButtonItemWithTitle:title normalImage:[UIImage imageNamed:@"segment-btn-center.png"] highlightedImage:[UIImage imageNamed:@"segment-btn-center-highlight.png"] disabledImage:[UIImage imageNamed:@"segment-btn-center-disabled.png"] target:target action:action];
}

+ (id)rightBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    return [self barButtonItemWithTitle:title normalImage:[UIImage imageNamed:@"segment-btn-right.png"] highlightedImage:[UIImage imageNamed:@"segment-btn-right-highlight.png"] disabledImage:[UIImage imageNamed:@"segment-btn-right-disabled.png"] target:target action:action];
}

@end
