//
//  DDInAppProductTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDInAppProductTableViewCell.h"
#import "UIImage+DD.h"
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
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)customizeOnce
{
    [super customizeOnce];
    
    self.labelPopular.text = NSLocalizedString(@"POPULAR!", nil);
    
    self.imageViewPopular.image = [self.imageViewPopular.image resizableImage];
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
