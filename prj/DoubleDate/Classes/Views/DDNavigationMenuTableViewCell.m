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

+ (CGFloat)height
{
    return 50;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
#warning customize here
    self.imageViewIcon.layer.borderWidth = 3;
    self.labelTitle.textColor = [UIColor redColor];
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
