//
//  DDNotificationTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDNotificationTableViewCell.h"
#import "DDNotification.h"
#import "DDShortUser.h"
#import "DDImageView.h"
#import "UIImage+DD.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

@interface DDNotificationTableViewCell ()

@property(nonatomic, retain) CAGradientLayer *innerGradientLayer;
//@property(nonatomic, retain) CALayer *upperSeperator;

@end

@implementation DDNotificationTableViewCell

@synthesize notification;
@synthesize imageView;
@synthesize imageViewWrapper;
@synthesize textViewContent;

+ (void)cutomizeTextView:(UITextView*)textView withNotification:(DDNotification*)notification
{
    //apply text
    NSString *createdAtString = [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @"Time ago"), notification.createdAtAgo];
    
    NSMutableAttributedString *attributedText = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %@", notification.notification, createdAtString]] autorelease];
    
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
    
    CGFloat minHeight = 70;
    
    [self cutomizeTextView:cell.textViewContent withNotification:notification];
    
    return MAX(minHeight, cell.textViewContent.frame.size.height + 20);
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

- (void)layoutSubviews
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.innerGradientLayer.frame = self.bounds;
    [CATransaction commit];
    [super layoutSubviews];
}

- (void)customizeOnce
{
    
    self.textViewContent.layer.shadowColor = [UIColor blackColor].CGColor;
    self.textViewContent.layer.shadowOffset = CGSizeMake(0, 1);
    self.textViewContent.layer.shadowRadius = 0;
    self.textViewContent.layer.shadowOpacity = 1;
    self.textViewContent.backgroundColor = [UIColor clearColor];
    
    // style user photo with border/inner-glow
    {
        self.imageViewWrapper.layer.borderColor = [UIColor blackColor].CGColor;
        self.imageViewWrapper.layer.borderWidth = 1.0f;
        self.imageViewWrapper.layer.cornerRadius = 6.0f;
        
        self.imageViewWrapper.layer.shadowOpacity = 0.3f;
        self.imageViewWrapper.layer.shadowRadius = 2.0f;
        self.imageViewWrapper.layer.shadowColor = [UIColor blackColor].CGColor;
        self.imageViewWrapper.layer.shadowOffset = CGSizeMake(0, 1);
        
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.cornerRadius = 7;
        
        // Inner white border on photo
        CALayer *innerGlowLayer = [CALayer layer];
        innerGlowLayer.frame = CGRectInset(self.imageView.bounds, 1, 1);
        innerGlowLayer.cornerRadius = 5;
        innerGlowLayer.borderWidth = 1;
        innerGlowLayer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.1f].CGColor;
        
        [self.imageViewWrapper.layer insertSublayer:innerGlowLayer atIndex:1];
    }

    // draw inner gradient
    [self drawInnerGradient];

    // [self drawInnerSeperators];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;

}

- (void)drawInnerGradient
{
    if (!self.innerGradientLayer)
    {
        self.innerGradientLayer = [CAGradientLayer layer];
        
        self.innerGradientLayer.opacity = 0.5f;
        
        self.innerGradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor],
                                                                 (id)[[UIColor blackColor] CGColor], nil];
        
        [self.layer insertSublayer:self.innerGradientLayer atIndex:0];
    }
}

//- (void)drawInnerSeperators
//{
//    if (!self.upperSeperator)
//    {
//        self.upperSeperator = [CALayer layer];
//        self.upperSeperator.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f].CGColor;
//
//        CGRect seperatorFrame = self.bounds;
//        seperatorFrame.size.height = 1;
//        
//        self.upperSeperator.frame = seperatorFrame;
//        [self.layer insertSublayer:self.upperSeperator above:self.innerShadowLayer];
//    }
//    
//}

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
        
        [self.imageView reloadFromUrl:[NSURL URLWithString:notification.photo.thumbUrl]];
        
        // Show unread styles
        // self.imageViewBadge.hidden = ![notification.unread boolValue];
        // self.innerBlueLayer.hidden = ![notification.unread boolValue];
    }
    else
    {
        self.textViewContent.attributedText = nil;
        self.textViewContent.text = nil;
    }
}

- (void)dealloc
{
    [notification release];
    [imageView release];
    [imageViewWrapper release];
    [textViewContent release];
    [_innerGradientLayer release];
//    [_upperSeperator release];
    [super dealloc];
}

@end