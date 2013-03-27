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
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    button.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1f];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    button.titleEdgeInsets = UIEdgeInsetsMake(1, 40, 0, 0);
    return button;
}

- (void)customizeTitleLabel:(UILabel*)label
{
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    label.textColor = [UIColor colorWithWhite:0.38f alpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.shadowOffset = CGSizeMake(0, 1);
    label.layer.shadowOpacity = 0.5f;
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowRadius = 1;
    label.layer.masksToBounds = NO;
}

- (void)customizeGenericLabel:(UILabel*)label
{
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
    label.textColor = [UIColor colorWithWhite:0.4f alpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.shadowOffset = CGSizeMake(0, 1);
    label.layer.shadowOpacity = 0.5f;
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowRadius = 1;
    label.layer.masksToBounds = NO;
}

- (void)applyNoDataWithImage:(UIImage*)image title:(NSString*)title addButtonTitle:(NSString*)buttonTitle addButtonTarget:(id)target addButtonAction:(SEL)action addButtonEdgeInsets:(UIEdgeInsets)insets detailed:(NSString*)detailed
{

    //add image view
    UIImageView *imageViewTop = [[[UIImageView alloc] initWithImage:image] autorelease];
    imageViewTop.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

    UILabel *labelTop = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 60)] autorelease];
    labelTop.numberOfLines = 2;
    labelTop.text = title;
    labelTop.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self customizeTitleLabel:labelTop];
    
    UIView *upperView = [[UIView alloc] initWithFrame:CGRectMake(20, 120, 280, imageViewTop.frame.size.height + labelTop.frame.size.height + 20)];
    
    CGRect labelFrame = upperView.bounds;
    labelFrame.size.height = 75;
    labelFrame.origin.y = upperView.frame.size.height - labelFrame.size.height;
    labelTop.frame = labelFrame;
    
    CGRect imageFrame = imageViewTop.frame;
    imageFrame.origin.x = upperView.frame.size.width/2 - imageFrame.size.width/2;
    imageViewTop.frame = imageFrame;
        
    [upperView addSubview:imageViewTop];
    [upperView addSubview:labelTop];
    
    //add label
    [self addSubview:upperView];
    
    // Center the label if there is no image (simple style, like no notifications)
    if (!image) {
        upperView.center = self.center;
    }

    UIView *lowerView = [[UIView alloc] initWithFrame:CGRectMake(20, self.frame.size.height - 160, 280, 120)];
    
    // add create date button
    if (buttonTitle && target && action)
    {
        UIImage *imageButton = [UIImage imageNamed:@"btn-blue-create.png"];
        UIButton *button = [self baseButtonWithImage:imageButton];
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        [lowerView addSubview:button];
        
        //add gradient background
        UIImageView *gradientView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-no-dates-centered.png"]] autorelease];
        gradientView.frame = CGRectMake(0, 0, 320, gradientView.image.size.height);
        gradientView.center = CGPointMake(button.center.x, button.center.y + 30);
        [lowerView insertSubview:gradientView belowSubview:button];
        
        //add label
        UILabel *labelBottom = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 60)] autorelease];
        labelBottom.center = CGPointMake(button.center.x, button.center.y + 55);
        labelBottom.numberOfLines = 2;
        labelBottom.text = detailed;
        [self customizeGenericLabel:labelBottom];
        
        [lowerView addSubview:labelBottom];

    }
    
    [self addSubview:lowerView];
    
}

- (void)applyNoDataWithMainText:(NSString*)mainText infoText:(NSString*)infoText
{
    
}

@end
