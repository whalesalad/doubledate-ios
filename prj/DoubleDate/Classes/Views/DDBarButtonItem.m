//
//  DDBarButtonItem.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDBarButtonItem.h"
#import "DDTools.h"
#import "DDAppDelegate.h"

@implementation DDBarButtonItem

@synthesize showsApplicationBadgeNumber;

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

+ (id)barButtonItemWithTitle:(NSString*)title normalImage:(UIImage*)normalImage highlightedImage:(UIImage*)highlightedImage disabledImage:(UIImage*)disabledImage target:(id)target action:(SEL)action contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets titleImage:(UIImage*)titleImage size:(CGFloat)size largeButtonFont:(BOOL)largeButtonFont padding:(NSInteger)padding
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (largeButtonFont)
        DD_F_BUTTON_LARGE(button);
    else
        DD_F_BUTTON(button);
    CGFloat width = [title sizeWithFont:button.titleLabel.font].width + normalImage.size.width;
    if (width < normalImage.size.height)
        width = normalImage.size.height;
    if (size != 0)
        width = size;
    width += 2 * padding;
    button.frame = CGRectMake(0, 0, width, normalImage.size.height);
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[[button titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5f] forState:UIControlStateDisabled];
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
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:contentEdgeInsets titleImage:nil size:0 largeButtonFont:NO padding:0];
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
    return [self barButtonItemWithTitle:nil normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsZero titleImage:image size:0 largeButtonFont:NO padding:0];
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
    UIEdgeInsets imageInsets = UIEdgeInsetsMake(15, 14, 15, 7);
    UIImage *normalImage = [[UIImage imageNamed:@"back-btn.png"] resizableImageWithCapInsets:imageInsets];
    UIImage *highlightedImage = [[UIImage imageNamed:@"back-btn-highlight.png"] resizableImageWithCapInsets:imageInsets];
    UIImage *disabledImage = [[UIImage imageNamed:@"back-btn.png"] resizableImageWithCapInsets:imageInsets];
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
}

+ (id)leftBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    UIImage *normalImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"dd-segmented-left-btn.png"]];
    UIImage *highlightedImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"dd-segmented-left-btn-highlight.png"]];
    UIImage *disabledImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"dd-segmented-left-btn-disabled.png"]];
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsZero titleImage:nil size:0 largeButtonFont:NO padding:4];
}

+ (id)leftLargeBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action size:(CGFloat)size
{
    UIEdgeInsets imageInsets = UIEdgeInsetsMake(23, 12, 23, 3);
    UIImage *normalImage = [[UIImage imageNamed:@"large-segment-left.png"] resizableImageWithCapInsets:imageInsets];
    UIImage *highlightedImage = [[UIImage imageNamed:@"large-segment-left-selected.png"] resizableImageWithCapInsets:imageInsets];
    UIImage *disabledImage = [[UIImage imageNamed:@"large-segment-left.png"] resizableImageWithCapInsets:imageInsets];
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsZero titleImage:nil size:size largeButtonFont:YES padding:0];
}

+ (id)middleBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    UIImage *normalImage = [UIImage imageNamed:@"dd-segmented-center-btn.png"];
    UIImage *highlightedImage = [UIImage imageNamed:@"dd-segmented-center-btn-highlight.png"];
    UIImage *disabledImage = [UIImage imageNamed:@"dd-segmented-center-btn-disabled.png"];
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsZero titleImage:nil size:0 largeButtonFont:NO padding:4];
}

+ (id)middleLargeBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action size:(CGFloat)size
{
    UIImage *normalImage = [UIImage imageNamed:@"large-segment-center.png"];
    UIImage *highlightedImage = [UIImage imageNamed:@"large-segment-center-selected.png"];
    UIImage *disabledImage = [UIImage imageNamed:@"large-segment-center.png"];
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsZero titleImage:nil size:size largeButtonFont:YES padding:0];
}

+ (id)rightBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    UIImage *normalImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"dd-segmented-right-btn.png"]];
    UIImage *highlightedImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"dd-segmented-right-btn-highlight.png"]];
    UIImage *disabledImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"dd-segmented-right-btn-disabled.png"]];
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsZero titleImage:nil size:0 largeButtonFont:NO padding:4];
}

+ (id)rightLargeBarButtonItemWithTitle:(NSString*)title target:(id)target action:(SEL)action size:(CGFloat)size
{
    UIEdgeInsets imageInsets = UIEdgeInsetsMake(23, 3, 23, 12);
    UIImage *normalImage = [[UIImage imageNamed:@"large-segment-right.png"] resizableImageWithCapInsets:imageInsets];
    UIImage *highlightedImage = [[UIImage imageNamed:@"large-segment-right-selected.png"] resizableImageWithCapInsets:imageInsets];
    UIImage *disabledImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"large-segment-right.png"]];
    return [self barButtonItemWithTitle:title normalImage:normalImage highlightedImage:highlightedImage disabledImage:disabledImage target:target action:action contentEdgeInsets:UIEdgeInsetsZero titleImage:nil size:size largeButtonFont:YES padding:0];
}

- (id)initWithCustomView:(UIView *)customView
{
    if ((self = [super initWithCustomView:customView]))
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateApplicationBadgeNumber) name:DDAppDelegateApplicationBadgeNumberUpdatedNotification object:nil];
    }
    return self;
}

- (void)updateApplicationBadgeNumber
{
    if (self.showsApplicationBadgeNumber)
    {
        self.showsApplicationBadgeNumber = NO;
        self.showsApplicationBadgeNumber = YES;
    }
}

- (void)setShowsApplicationBadgeNumber:(BOOL)v
{
    //check for new value
    if (v != self.showsApplicationBadgeNumber)
    {
        //update value
        showsApplicationBadgeNumber = v;
        
        //set tag
        NSInteger tagBadge = 2134;
        
        //remove previous badge
        [[self.customView viewWithTag:tagBadge] removeFromSuperview];
        
        //check if we need to show the label
        if (v)
        {
            //add badge
            UIImageView *imageViewBadge = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notification-bubble.png"]] autorelease];
            imageViewBadge.tag = tagBadge;
            imageViewBadge.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            imageViewBadge.center = CGPointMake(self.customView.frame.size.width + 4, self.customView.frame.size.height/2);
            [self.customView addSubview:imageViewBadge];
            
            //hide application badge number if it's not more than 0
            imageViewBadge.hidden = [[UIApplication sharedApplication] applicationIconBadgeNumber] <= 0;
            
            //add label
            UILabel *label = [[[UILabel alloc] initWithFrame:imageViewBadge.bounds] autorelease];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
            label.shadowOffset = CGSizeMake(0, 1);
            label.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
            label.backgroundColor = [UIColor clearColor];
            label.text = [NSString stringWithFormat:@"%d", [[UIApplication sharedApplication] applicationIconBadgeNumber]];
            label.textAlignment = NSTextAlignmentCenter;
            [imageViewBadge addSubview:label];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [normalImage_ release];
    [highlightedImage_ release];
    [disabledImage_ release];
    [button_ release];
    [super dealloc];
}

@end
