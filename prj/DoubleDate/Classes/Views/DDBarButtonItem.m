//
//  DDBarButtonItem.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDBarButtonItem.h"

@implementation DDBarButtonItem

+ (id)barButtonItemWithTitle:(NSString*)title normalImage:(UIImage*)normalImage highlightedImage:(UIImage*)highlightedImage target:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    normalImage = [normalImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, normalImage.size.width/2, 0, normalImage.size.width/2)];
    highlightedImage = [highlightedImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, highlightedImage.size.width/2, 0, highlightedImage.size.width/2)];
    [button setBackgroundImage:normalImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    button.frame = CGRectMake(0, 0, normalImage.size.width+[title sizeWithFont:button.titleLabel.font].width+10, normalImage.size.height);
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[[DDBarButtonItem alloc] initWithCustomView:button] autorelease];
}

+ (id)barButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    return [self barButtonItemWithTitle:title normalImage:[UIImage imageNamed:@"nav-btn.png"] highlightedImage:[UIImage imageNamed:@"nav-btn-highlight.png"] target:target action:action];
}

+ (id)backBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    return [self barButtonItemWithTitle:title normalImage:[UIImage imageNamed:@"back-btn.png"] highlightedImage:[UIImage imageNamed:@"back-btn-highlight.png"] target:target action:action];
}

@end
