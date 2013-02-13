//
//  DDEngagementTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDEngagementTableViewCell.h"
#import "DDEngagement.h"
#import "DDShortUser.h"
#import "DDImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface DDEngagementTableViewCell ()

@property(nonatomic, retain) UIView *viewBlueGlow;

@end

@implementation DDEngagementTableViewCell

@synthesize viewBlueGlow;

@synthesize engagement;

@synthesize imageViewUser;
@synthesize imageViewWing;
@synthesize viewEffects;
@synthesize labelTitle;
@synthesize labelDetailed;
@synthesize viewImagesContainer;
@synthesize imageViewBadge;

+ (CGFloat)height
{
    return 108;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.viewBlueGlow = [[[UIView alloc] initWithFrame:viewImagesContainer.frame] autorelease];
        [self insertSubview:self.viewBlueGlow atIndex:4];
    }
    return self;
}

- (void)customize
{    
    viewEffects.layer.borderColor = [UIColor blackColor].CGColor;
    viewEffects.layer.borderWidth = 1;
    
    viewEffects.layer.shadowColor = [UIColor blackColor].CGColor;
    viewEffects.layer.shadowOffset = CGSizeMake(0, 1);
    viewEffects.layer.shadowRadius = 1;
    viewEffects.layer.shadowOpacity = 0.4f;
    viewEffects.layer.shadowPath = [[UIBezierPath bezierPathWithRect:viewEffects.bounds] CGPath];
    
    viewImagesContainer.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1].CGColor;
    viewImagesContainer.layer.borderWidth = 1;
    
    // add inner blue glow
    self.viewBlueGlow.frame = viewImagesContainer.frame;
    self.viewBlueGlow.backgroundColor = [UIColor colorWithRed:0 green:152.0/255.0 blue:216.0/255.0 alpha:0.4f];
    CAGradientLayer *blueGlowGradient = [CAGradientLayer layer];
    blueGlowGradient.frame = self.viewBlueGlow.bounds;
    blueGlowGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor],
                                                        (id)[[UIColor blackColor] CGColor], nil];
    self.viewBlueGlow.layer.mask = blueGlowGradient;
    
        
    // unset background
    labelDetailed.backgroundColor = [UIColor clearColor];
    labelTitle.backgroundColor = [UIColor clearColor];
}

- (void)setEngagement:(DDEngagement *)v
{
    //check for the same instance
    if (v != engagement)
    {
        //update value
        [engagement release];
        engagement = [v retain];
        
        //check friend
        if (engagement)
        {
            //apply text
            self.labelTitle.text = [NSString stringWithFormat:@"%@", engagement.activityTitle];
            
            self.labelDetailed.text = [NSString stringWithFormat:@"%@ & %@ — %@ ago", engagement.user.firstName, engagement.wing.firstName, engagement.updatedAtAgo];
            
            //apply genders
            [self.imageViewUser reloadFromUrl:[NSURL URLWithString:engagement.user.photo.smallUrl]];
            [self.imageViewWing reloadFromUrl:[NSURL URLWithString:engagement.wing.photo.smallUrl]];
            
            //apply unread count
            if ([engagement.unreadCount intValue] > 0)
            {
                self.viewImagesContainer.layer.borderColor = [UIColor colorWithRed:0 green:152.0/255.0 blue:216.0/255.0 alpha:0.7f].CGColor;
            } else
            {
                self.imageViewBadge.hidden = YES;
                self.viewBlueGlow.hidden = YES;
            }
        }
        else
        {
            self.labelTitle.text = nil;
            self.labelDetailed.text = nil;
            self.imageViewUser.image = nil;
            self.imageViewWing.image = nil;
            self.imageViewBadge.hidden = YES;
            self.viewBlueGlow.hidden = YES;
        }
    }
}

- (void)dealloc
{
    [engagement release];
    [imageViewUser release];
    [imageViewWing release];
    [viewEffects release];
    [labelTitle release];
    [labelDetailed release];
    [viewImagesContainer release];
    [imageViewBadge release];
    [viewBlueGlow release];
    [super dealloc];
}

@end
