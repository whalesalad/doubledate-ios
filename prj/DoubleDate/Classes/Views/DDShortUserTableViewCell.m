//
//  DDShortUserTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDShortUserTableViewCell.h"
#import "DDShortUser.h"
#import "DDImageView.h"
#import "DDWingTableViewCell.h"
#import "DDUser.h"
#import "UIImage+DD.h"
#import <QuartzCore/QuartzCore.h>

@interface DDShortUserTableViewCell ()

@property(nonatomic, retain) UIView *topBorderView;

@end

@implementation DDShortUserTableViewCell

@synthesize shortUser;

@synthesize labelTitle;
@synthesize imageViewWrapper;
@synthesize imageViewPoster;
@synthesize imageViewCheckmark;
@synthesize topBorderView;

+ (CGFloat)height
{
    return 55;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.topBorderView = [[[UIView alloc] init] autorelease];
        [self.imageViewPoster addSubview:self.topBorderView];
    }
    return self;
}

- (void)customize
{    
    //set background view
    self.backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"dark-tableview-bg.png"] resizableImage]] autorelease];
    
    //hide checkmark
    imageViewCheckmark.hidden = YES;
    
    //unset background
    labelTitle.backgroundColor = [UIColor clearColor];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)setShortUser:(DDShortUser *)v
{
    //apply new value
    if (v != shortUser)
    {
        [shortUser release];
        shortUser = [v retain];
    }
    
    //update ui
    imageViewPoster.image = nil;
    if (v.photo.thumbUrl && [NSURL URLWithString:v.photo.thumbUrl])
        [imageViewPoster reloadFromUrl:[NSURL URLWithString:v.photo.thumbUrl]];

    labelTitle.text = [DDShortUser nameForShortUser:shortUser];
    labelTitle.frame = CGRectMake(labelTitle.frame.origin.x, labelTitle.frame.origin.y, [labelTitle sizeThatFits:labelTitle.bounds.size].width, labelTitle.frame.size.height);
}

- (void)dealloc
{
    [shortUser release];
    [labelTitle release];
    [imageViewPoster release];
    [imageViewCheckmark release];
    [topBorderView release];
    [super dealloc];
}

@end
