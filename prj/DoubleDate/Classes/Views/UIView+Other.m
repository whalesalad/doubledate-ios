//
//  UIView+Other.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "UIView+Other.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Other)

- (UIButton*)baseButtonWithImage:(UIImage*)image
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    button.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.2f];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    return button;
}

- (void)customizeTitleLabel:(UILabel*)label
{
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    label.textColor = [UIColor colorWithWhite:0.8f alpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.shadowOffset = CGSizeMake(0, 1);
    label.layer.shadowOpacity = 1.0f;
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowRadius = 1;
    label.layer.masksToBounds = NO;
}

- (void)customizeGenericLabel:(UILabel*)label
{
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
    label.textColor = [UIColor colorWithWhite:0.8f alpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.shadowOffset = CGSizeMake(0, 1);
    label.layer.shadowOpacity = 1.0f;
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowRadius = 1;
    label.layer.masksToBounds = NO;
}

- (void)applyNoDataWithImage:(UIImage*)image title:(NSString*)title addButtonTitle:(NSString*)buttonTitle addButtonTarget:(id)target addButtonAction:(SEL)action addButtonEdgeInsets:(UIEdgeInsets)insets detailed:(NSString*)detailed
{
    //add create date button
    UIImage *imageButton = [UIImage imageNamed:@"btn-blue-create.png"];
    UIButton *button = [self baseButtonWithImage:imageButton];
    button.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2+54);
    button.titleEdgeInsets = insets;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:buttonTitle forState:UIControlStateNormal];
    [self addSubview:button];
    
    //add gradient background
    UIImageView *gradientView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-no-dates-centered.png"]] autorelease];
    gradientView.frame = CGRectMake(0, 0, 320, gradientView.image.size.height);
    gradientView.center = CGPointMake(button.center.x, button.center.y - 32);
    [self insertSubview:gradientView belowSubview:button];
    
    //add image view
    UIImageView *imageViewTop = [[[UIImageView alloc] initWithImage:image] autorelease];
    imageViewTop.center = CGPointMake(button.center.x, button.center.y - 182);
    [self addSubview:imageViewTop];
    
    //add label
    UILabel *labelTop = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 60)] autorelease];
    labelTop.center = CGPointMake(button.center.x, button.center.y - 82);
    labelTop.numberOfLines = 2;
    labelTop.text = title;
    [self customizeTitleLabel:labelTop];
    [self addSubview:labelTop];
    
    //add label
    UILabel *labelBottom = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 60)] autorelease];
    labelBottom.center = CGPointMake(button.center.x, button.center.y + 24);
    labelBottom.numberOfLines = 2;
    labelBottom.text = detailed;
    [self customizeGenericLabel:labelBottom];
    [self addSubview:labelBottom];
}

@end
