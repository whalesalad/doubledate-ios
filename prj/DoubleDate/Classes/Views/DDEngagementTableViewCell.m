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
#import "DDAuthenticationController.h"
#import "DDUser.h"
#import <QuartzCore/QuartzCore.h>

@interface DDEngagementTableViewCell ()

@property(nonatomic, retain) CAGradientLayer *innerBlueLayer;

@end

@implementation DDEngagementTableViewCell

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
    
    [self drawInnerBlueLayer];
        
    // unset background
    labelDetailed.backgroundColor = [UIColor clearColor];
    labelTitle.backgroundColor = [UIColor clearColor];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;

}

- (void)drawInnerBlueLayer
{
    if (!self.innerBlueLayer)
    {
        self.innerBlueLayer = [CAGradientLayer layer];
        
        self.innerBlueLayer.colors = [NSArray arrayWithObjects:
                                      (id)[[UIColor colorWithRed:0 green:152.0/255.0 blue:216.0/255.0 alpha:0.3f] CGColor],
                                      (id)[[UIColor colorWithRed:0 green:152.0/255.0 blue:216.0/255.0 alpha:0.1f] CGColor],
                                      nil];
        
        self.innerBlueLayer.frame = self.viewImagesContainer.frame;
        
        [self.layer insertSublayer:self.innerBlueLayer below:imageViewBadge.layer];
        
        self.innerBlueLayer.hidden = YES;
    }
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
            //check if authenticated user is in activity
            BOOL authenticatedUserIsInActivity = [[[DDAuthenticationController currentUser] userId] intValue] == [[[engagement activityUser] identifier] intValue] || [[[DDAuthenticationController currentUser] userId] intValue] == [[[engagement activityWing] identifier] intValue];
            DDShortUser *userToShow = authenticatedUserIsInActivity?engagement.user:engagement.activityUser;
            DDShortUser *wingToShow = authenticatedUserIsInActivity?engagement.wing:engagement.activityWing;
            
            //apply text
            self.labelTitle.text = [NSString stringWithFormat:@"%@", engagement.activityTitle];
            
            //update users label
            self.labelDetailed.text = [NSString stringWithFormat:@"%@ & %@ — %@ ago", userToShow.firstName, wingToShow.firstName, engagement.updatedAtAgo];
            
            //apply genders
            [self.imageViewUser reloadFromUrl:[NSURL URLWithString:userToShow.photo.smallUrl]];
            [self.imageViewWing reloadFromUrl:[NSURL URLWithString:wingToShow.photo.smallUrl]];
            
            //apply unread count
            self.imageViewBadge.hidden = [engagement.unreadCount intValue] == 0;
            self.innerBlueLayer.hidden = [engagement.unreadCount intValue] == 0;
        }
        else
        {
            self.labelTitle.text = nil;
            self.labelDetailed.text = nil;
            self.imageViewUser.image = nil;
            self.imageViewWing.image = nil;
            self.imageViewBadge.hidden = YES;
            self.innerBlueLayer.hidden = YES;
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
    [_innerBlueLayer release];
    [super dealloc];
}

@end
