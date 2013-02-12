//
//  DDNotificationTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDNotificationTableViewCell.h"
#import "DDNotification.h"
#import "DDShortUser.h"
#import "DDImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface DDNotificationTableViewCell ()

@property(nonatomic, retain) UIView *viewBlueGlow;

@end

@implementation DDNotificationTableViewCell

@synthesize viewBlueGlow;

@synthesize notification;

@synthesize imageViewUser;
@synthesize imageViewWing;
@synthesize viewEffects;
@synthesize labelTitle;
@synthesize labelDetailed;
@synthesize viewImagesContainer;
@synthesize imageViewBadge;

+ (CGFloat)heightForNotification:(DDNotification*)notification
{
    return 108;
}

+ (CGFloat)height
{
    return [self heightForNotification:nil];
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
    self.viewBlueGlow = [[[UIView alloc] initWithFrame:viewImagesContainer.frame] autorelease];
    self.viewBlueGlow.backgroundColor = [UIColor colorWithRed:0 green:152.0/255.0 blue:216.0/255.0 alpha:0.4f];
    CAGradientLayer *blueGlowGradient = [CAGradientLayer layer];
    blueGlowGradient.frame = self.viewBlueGlow.bounds;
    blueGlowGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor],
                                                        (id)[[UIColor blackColor] CGColor], nil];
    self.viewBlueGlow.layer.mask = blueGlowGradient;
    [self insertSubview:self.viewBlueGlow atIndex:4];
        
    // unset background
    labelDetailed.backgroundColor = [UIColor clearColor];
    labelTitle.backgroundColor = [UIColor clearColor];
}

- (void)setNotification:(DDNotification *)v
{
    //check for the same instance
    if (v != notification)
    {
        //update value
        [notification release];
        notification = [v retain];
        
        //check friend
        if (notification)
        {
            //apply text
            self.labelTitle.text = [NSString stringWithFormat:@"%@", notification.notification];
            
            self.labelDetailed.text = [NSString stringWithFormat:@"%@", notification.createdAtAgo];
            
            //apply genders
            if ([notification.photos count] == 2)
            {
                [self.imageViewUser reloadFromUrl:[NSURL URLWithString:[[notification.photos objectAtIndex:0] smallUrl]]];
                [self.imageViewWing reloadFromUrl:[NSURL URLWithString:[[notification.photos objectAtIndex:1] smallUrl]]];
            }
            else
            {
                [self.imageViewUser reloadFromUrl:nil];
                [self.imageViewWing reloadFromUrl:nil];
            }
            
            //apply unread count
            if ([notification.unread intValue] > 0)
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
    [notification release];
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
