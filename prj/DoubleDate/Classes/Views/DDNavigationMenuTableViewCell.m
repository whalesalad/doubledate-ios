//
//  DDNavigationMenuTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDNavigationMenuTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation DDNavigationMenuTableViewCell

@synthesize imageViewIcon;
@synthesize labelTitle;
@synthesize imageViewBadge;
@synthesize labelBadge;
@synthesize highlightLine;

+ (CGFloat)height
{
    return 50;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.highlightLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1.0f)];
        [self addSubview:self.highlightLine];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // customize highlight line
    self.highlightLine.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.highlightLine.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
    self.highlightLine.hidden = true;
    
    self.backgroundColor = [UIColor clearColor];
    
    // Apply shadows to icon and label.
    [self drawShadowForView:self.imageViewIcon];
    [self drawShadowForView:self.labelTitle];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)drawShadowForView:(UIView *)aView
{
    aView.layer.shadowColor = [UIColor blackColor].CGColor;
    aView.layer.shadowOffset = CGSizeMake(0, 1.0f);
    aView.layer.shadowOpacity = 0.7f;
    aView.layer.shadowRadius = 1.0f;
    aView.clipsToBounds = NO;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        self.imageViewIcon.layer.opacity = 0.8f;
        self.labelTitle.layer.opacity = 0.8f;
        self.highlightLine.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    } else {
        self.backgroundColor = [UIColor clearColor];
        self.imageViewIcon.layer.opacity = 1.0f;
        self.labelTitle.layer.opacity = 1.0f;
        self.highlightLine.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
    }
}

- (void)dealloc
{
    [imageViewIcon release];
    [labelTitle release];
    [imageViewBadge release];
    [labelBadge release];
    [super dealloc];
}

@end
