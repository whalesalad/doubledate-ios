//
//  DDChooseWingTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDChooseWingTableViewCell.h"
#import "DDShortUser.h"
#import "DDImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface DDChooseWingTableViewCell ()

@property(nonatomic, retain) CALayer *innerGlowLayer;
@property(nonatomic, retain) CAGradientLayer *glowLayerMask, *innerShadowLayer;

@end

@implementation DDChooseWingTableViewCell

@synthesize imageViewUser;
@synthesize labelName;
@synthesize wrapperView;

@synthesize shortUser;

+ (CGFloat)height
{
    return 110;
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
    self.wrapperView.clipsToBounds = NO;
    
    self.wrapperView.layer.borderColor = [UIColor blackColor].CGColor;
    self.wrapperView.layer.borderWidth = 1;
    
    self.wrapperView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.wrapperView.layer.shadowOffset = CGSizeMake(0, 1);
    self.wrapperView.layer.shadowRadius = 1;
    self.wrapperView.layer.shadowOpacity = 0.4f;
    
    [self drawInnerGlow];
    [self drawInnerShadow];
    
    self.innerShadowLayer.frame = CGRectInset(self.wrapperView.bounds, 1, 1);
    self.innerGlowLayer.frame = CGRectInset(self.wrapperView.bounds, 1, 1);
    self.glowLayerMask.frame = self.wrapperView.bounds;
    
    self.labelName.layer.shadowColor = [UIColor blackColor].CGColor;
    self.labelName.layer.shadowOffset = CGSizeMake(0, 1);
    self.labelName.layer.shadowRadius = 0;
    self.labelName.layer.shadowOpacity = 1;
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)drawInnerGlow
{
    if (!self.innerGlowLayer)
    {
        self.innerGlowLayer = [CALayer layer];
        self.innerGlowLayer.borderWidth = 1;
        self.innerGlowLayer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.1f].CGColor;
        
        self.glowLayerMask = [CAGradientLayer layer];
        self.glowLayerMask.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor],
                                     (id)[[UIColor clearColor] CGColor], nil];
        
        self.innerGlowLayer.mask = self.glowLayerMask;
        
        [self.wrapperView.layer insertSublayer:self.innerGlowLayer atIndex:1];
    }
}

- (void)drawInnerShadow
{
    if (!self.innerShadowLayer)
    {
        self.innerShadowLayer = [CAGradientLayer layer];
        
        self.innerShadowLayer.opacity = 0.8f;
        
        self.innerShadowLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor],
                                        (id)[[UIColor clearColor] CGColor],
                                        (id)[[UIColor colorWithWhite:0 alpha:0.6f] CGColor],
                                        (id)[[UIColor blackColor] CGColor], nil];
        
        [self.wrapperView.layer insertSublayer:self.innerShadowLayer atIndex:2];
    }
}

- (void)setShortUser:(DDShortUser *)v
{
    //apply new value
    if (v != shortUser)
    {
        [shortUser release];
        shortUser = [v retain];
    }
    
    //set image view
    [self.imageViewUser reloadFromUrl:[NSURL URLWithString:shortUser.photo.smallUrl]];
    
    //set label
    self.labelName.text = shortUser.firstName;
}

- (void)dealloc
{
    [imageViewUser release];
    [labelName release];
    [shortUser release];
    [wrapperView release];
    [super dealloc];
}

@end
