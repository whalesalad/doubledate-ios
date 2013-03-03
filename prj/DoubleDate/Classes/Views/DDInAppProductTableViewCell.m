//
//  DDInAppProductTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDInAppProductTableViewCell.h"
#import "DDTools.h"
#import <QuartzCore/QuartzCore.h>

@implementation DDInAppProductTableViewCell

@synthesize labelAmount;
@synthesize labelCost;
@synthesize labelPopular;
@synthesize imageViewPopular;

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

- (void)customizeOnce
{
    [super customizeOnce];
    
    self.imageViewPopular.image = [DDTools resizableImageFromImage:self.imageViewPopular.image];
}

- (void)dealloc
{
    [labelAmount release];
    [labelCost release];
    [labelPopular release];
    [imageViewPopular release];
    [super dealloc];
}

@end
