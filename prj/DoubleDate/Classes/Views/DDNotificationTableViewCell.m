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
#import "DDTools.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

@interface DDNotificationTableViewCell ()

@property(nonatomic, retain) CALayer *innerGlowLayer;
@property(nonatomic, retain) CAGradientLayer *glowLayerMask, *innerShadowLayer, *innerBlueLayer;

@end

@implementation DDNotificationTableViewCell

@synthesize notification;

@synthesize imageViewLeft;
@synthesize imageViewRight;
@synthesize imageViewFull;
@synthesize textViewContent;
@synthesize viewImagesContainer;
@synthesize imageViewBadge;
@synthesize imageViewBackground;
@synthesize wrapperView;

+ (void)cutomizeTextView:(UITextView*)textView withNotification:(DDNotification*)notification
{
    //apply text
    NSString *createdAtString = [NSString stringWithFormat:@" %@ ago", notification.createdAtAgo];
    
    NSMutableAttributedString *attributedText = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", notification.notification, createdAtString]] autorelease];
    
    NSString *mainFontName = ([notification.unread boolValue]) ? @"HelveticaNeue-Bold" : @"HelveticaNeue";
    
    //cutomize notification
    NSRange rangeMain = NSMakeRange(0, [notification.notification length]);
    [attributedText addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:mainFontName size:15]
                           range:rangeMain];
    [attributedText addAttribute:NSForegroundColorAttributeName
                           value:[UIColor whiteColor]
                           range:rangeMain];
    
    //cutomize date
    NSRange rangeDate = NSMakeRange([[attributedText string] length] - [createdAtString length], [createdAtString length]);
    [attributedText addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:@"HelveticaNeue" size:13]
                           range:rangeDate];
    [attributedText addAttribute:NSForegroundColorAttributeName
                           value:[UIColor lightGrayColor]
                           range:rangeDate];
    
    // apply attributed text
    textView.attributedText = attributedText;
    
    CGRect textViewFrame = textView.frame;
    textViewFrame.size.height = textView.contentSize.height - 15;
    textView.frame = textViewFrame;
    
}

+ (CGFloat)heightForNotification:(DDNotification*)notification
{
    DDNotificationTableViewCell *cell = (DDNotificationTableViewCell*)[[[UINib nibWithNibName:@"DDNotificationTableViewCell" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    
    CGFloat minHeight = cell.frame.size.height - cell.textViewContent.frame.size.height;
    
    [self cutomizeTextView:cell.textViewContent withNotification:notification];
    
    return minHeight + cell.textViewContent.frame.size.height;
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

- (void)customizeOnce
{
    [self drawInnerGlow];
    [self drawInnerShadow];
    [self drawInnerBlueLayer];

    self.imageViewLeft.contentMode = UIViewContentModeScaleAspectFill;
    self.imageViewRight.contentMode = UIViewContentModeScaleAspectFill;
    self.imageViewFull.center = self.center;
    
    self.imageViewLeft.layer.opacity = 0.3f;
    self.imageViewRight.layer.opacity = 0.3f;
    self.imageViewFull.layer.opacity = 0.3f;
    
    self.textViewContent.layer.shadowColor = [UIColor blackColor].CGColor;
    self.textViewContent.layer.shadowOffset = CGSizeMake(0, 1);
    self.textViewContent.layer.shadowRadius = 0;
    self.textViewContent.layer.shadowOpacity = 1;
    
    self.textViewContent.backgroundColor = [UIColor clearColor];
    self.imageViewBackground.image = [DDTools resizableImageFromImage:imageViewBackground.image];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;

}

- (void)layoutSubviews
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.innerShadowLayer.frame = self.wrapperView.bounds;
    self.innerBlueLayer.frame = self.wrapperView.bounds;
    self.innerGlowLayer.frame = self.wrapperView.bounds;
    self.glowLayerMask.frame = self.innerGlowLayer.bounds;
    [CATransaction commit];
    [super layoutSubviews];
}

- (void)drawInnerGlow
{
    if (!self.innerGlowLayer)
    {
        // Inner white/blue border
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

- (void)drawInnerBlueLayer
{
    if (!self.innerBlueLayer)
    {
        self.innerBlueLayer = [CAGradientLayer layer];
        
        self.innerBlueLayer.colors = [NSArray arrayWithObjects:
                                        (id)[[UIColor colorWithRed:0 green:152.0/255.0 blue:216.0/255.0 alpha:0.3f] CGColor],
                                        (id)[[UIColor colorWithRed:0 green:152.0/255.0 blue:216.0/255.0 alpha:0.1f] CGColor],
                                      nil];
        
        [self.wrapperView.layer insertSublayer:self.innerBlueLayer atIndex:3];
        
        self.innerBlueLayer.hidden = YES;
    }
}

- (void)setNotification:(DDNotification *)v
{
    //check for the same instance
    if (v != notification)
    {
        //update value
        [notification release];
        notification = [v retain];
    }
    
    //check object
    if (notification)
    {
        //customize content
        [DDNotificationTableViewCell cutomizeTextView:self.textViewContent withNotification:notification];
        
        //apply genders
        imageViewFull.hidden = [notification.photos count] != 1;
        imageViewLeft.hidden = [notification.photos count] != 2;
        imageViewRight.hidden = [notification.photos count] != 2;
        if ([notification.photos count] == 2)
        {
            [self.imageViewLeft reloadFromUrl:[NSURL URLWithString:[[notification.photos objectAtIndex:0] smallUrl]]];
            [self.imageViewRight reloadFromUrl:[NSURL URLWithString:[[notification.photos objectAtIndex:1] smallUrl]]];
        }
        else if ([notification.photos count] == 1)
        {
            [self.imageViewFull reloadFromUrl:[NSURL URLWithString:[[notification.photos objectAtIndex:0] mediumUrl]]];
        }
        
        // Show unread styles
        self.imageViewBadge.hidden = ![notification.unread boolValue];
        self.innerBlueLayer.hidden = ![notification.unread boolValue];
    }
    else
    {
        self.textViewContent.attributedText = nil;
        self.textViewContent.text = nil;
        self.imageViewLeft.image = nil;
        self.imageViewRight.image = nil;
        self.imageViewFull.image = nil;
        self.imageViewBadge.hidden = YES;
        self.innerBlueLayer.hidden = YES;
    }
}

- (void)dealloc
{
    [notification release];
    [imageViewLeft release];
    [imageViewRight release];
    [imageViewFull release];
    [textViewContent release];
    [viewImagesContainer release];
    [imageViewBadge release];
    [imageViewBackground release];
    [wrapperView release];
    [_innerGlowLayer release];
    [_innerShadowLayer release];
    [_innerBlueLayer release];
    [_glowLayerMask release];
    [super dealloc];
}

@end