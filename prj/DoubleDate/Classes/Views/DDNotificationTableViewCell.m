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

@property(nonatomic, retain) UIView *innerBorderView;

@end

@implementation DDNotificationTableViewCell

@synthesize notification;

@synthesize imageViewLeft;
@synthesize imageViewRight;
@synthesize imageViewFull;
@synthesize textViewContent;
@synthesize viewImagesContainer;
@synthesize imageViewBadge;
@synthesize imageViewGlow;
@synthesize imageViewBackground;
@synthesize wrapperView;

+ (void)cutomizeTextView:(UITextView*)textView withNotification:(DDNotification*)notification
{
    //apply text
    NSString *createdAtString = [NSString stringWithFormat:@" %@ ago", notification.createdAtAgo];
    
    NSMutableAttributedString *attributedText = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", notification.notification, createdAtString]] autorelease];
    
    NSString *mainFontName = ([notification.unread intValue] > 0) ? @"HelveticaNeue-Bold" : @"HelveticaNeue-Medium";
    
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

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIView *shadowView = [[[UIView alloc] initWithFrame:wrapperView.bounds] autorelease];
    shadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    CAGradientLayer *shadowGradientMask = [CAGradientLayer layer];
    shadowGradientMask.frame = shadowView.bounds;
    shadowGradientMask.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor],
                                                          (id)[[UIColor clearColor] CGColor],
                                                          (id)[[UIColor colorWithWhite:0 alpha:0.6f] CGColor],
                                                          (id)[[UIColor blackColor] CGColor], nil];
    
    shadowView.layer.mask = shadowGradientMask;
    
    // Add inner white border with mask
    self.innerBorderView = [[[UIView alloc] initWithFrame:wrapperView.bounds] autorelease];
    self.innerBorderView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.innerBorderView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1].CGColor;
    self.innerBorderView.layer.borderWidth = 1;
    
    // mask for inner white border
    CAGradientLayer *innerBorderMask = [CAGradientLayer layer];
    innerBorderMask.frame = self.innerBorderView.bounds;
    innerBorderMask.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor],
                                                       (id)[[UIColor clearColor] CGColor], nil];
    self.innerBorderView.layer.mask = innerBorderMask;
    
    // Insert inner border first, followed by shadow
    [self.wrapperView insertSubview:self.innerBorderView belowSubview:self.textViewContent];
    [self.wrapperView insertSubview:shadowView belowSubview:self.textViewContent];
    
    self.imageViewLeft.contentMode = UIViewContentModeScaleAspectFill;
    self.imageViewRight.contentMode = UIViewContentModeScaleAspectFill;
    self.imageViewFull.center = self.center;
    
    self.imageViewLeft.layer.opacity = 0.3f;
    self.imageViewRight.layer.opacity = 0.3f;
    self.imageViewFull.layer.opacity = 0.3f;
    
    self.textViewContent.backgroundColor = [UIColor clearColor];
    self.imageViewBackground.image = [DDTools resizableImageFromImage:imageViewBackground.image];
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
            
            //apply unread count
            if ([notification.unread intValue] > 0)
            {
                self.innerBorderView.layer.borderColor = [UIColor colorWithRed:0 green:152.0/255.0 blue:216.0/255.0 alpha:0.7f].CGColor;
                self.imageViewBadge.hidden = NO;
                self.imageViewGlow.hidden = NO;
            }
            else
            {
                self.innerBorderView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1].CGColor;
                self.imageViewBadge.hidden = YES;
                self.imageViewGlow.hidden = YES;
            }
        }
        else
        {
            self.textViewContent.attributedText = nil;
            self.textViewContent.text = nil;
            self.imageViewLeft.image = nil;
            self.imageViewRight.image = nil;
            self.imageViewFull.image = nil;
            self.imageViewBadge.hidden = YES;
            self.imageViewGlow.hidden = YES;
        }
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
    [imageViewGlow release];
    [imageViewBackground release];
    [wrapperView release];
    [super dealloc];
}

@end
