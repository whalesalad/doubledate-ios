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

@end

@implementation DDNotificationTableViewCell

@synthesize notification;

@synthesize imageViewLeft;
@synthesize imageViewRight;
@synthesize imageViewFull;
@synthesize viewEffects;
@synthesize textViewContent;
@synthesize viewImagesContainer;
@synthesize imageViewBadge;
@synthesize imageViewGlow;
@synthesize imageViewBackground;

+ (void)cutomizeTextView:(UITextView*)textView withNotification:(DDNotification*)notification
{
    //apply text
    NSMutableAttributedString *attributedText = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", notification.notification, notification.createdAtAgo]] autorelease];
    
    //cutomize notification
    NSRange rangeMain = NSMakeRange(0, [notification.notification length]);
    [attributedText addAttribute:NSFontAttributeName
                           value:[UIFont systemFontOfSize:15]
                           range:rangeMain];
    [attributedText addAttribute:NSForegroundColorAttributeName
                           value:[UIColor redColor]
                           range:rangeMain];
    
    //cutomize date
    NSRange rangeDate = NSMakeRange([[attributedText string] length] - [notification.createdAtAgo length], [notification.createdAtAgo length]);
    [attributedText addAttribute:NSFontAttributeName
                           value:[UIFont systemFontOfSize:11]
                           range:rangeDate];
    [attributedText addAttribute:NSForegroundColorAttributeName
                           value:[UIColor greenColor]
                           range:rangeDate];
    
    //apply attributed text
    textView.attributedText = attributedText;
    
    //apply needed offset
    if (textView.contentSize.height < textView.frame.size.height)
        textView.contentOffset = CGPointMake(0, -(textView.frame.size.height - textView.contentSize.height) / 2);
    else
        textView.contentOffset = CGPointZero;
}

+ (CGFloat)heightForNotification:(DDNotification*)notification
{
    DDNotificationTableViewCell *cell = (DDNotificationTableViewCell*)[[[UINib nibWithNibName:@"DDNotificationTableViewCell" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    CGFloat minHeight = cell.frame.size.height;
    [self cutomizeTextView:cell.textViewContent withNotification:notification];
    return MAX(cell.frame.size.height - cell.textViewContent.frame.size.height + cell.textViewContent.contentSize.height + cell.textViewContent.contentInset.top + cell.textViewContent.contentInset.bottom, minHeight);
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
    
    self.textViewContent.backgroundColor = [UIColor clearColor];
    
    self.imageViewLeft.contentMode = UIViewContentModeScaleAspectFill;
    self.imageViewRight.contentMode = UIViewContentModeScaleAspectFill;
    self.imageViewFull.contentMode = UIViewContentModeScaleAspectFill;
    
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
                self.viewImagesContainer.layer.borderColor = [UIColor colorWithRed:0 green:152.0/255.0 blue:216.0/255.0 alpha:0.7f].CGColor;
                self.imageViewBadge.hidden = NO;
                self.imageViewGlow.hidden = NO;
            }
            else
            {
                viewImagesContainer.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1].CGColor;
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
    [viewEffects release];
    [textViewContent release];
    [viewImagesContainer release];
    [imageViewBadge release];
    [imageViewGlow release];
    [imageViewBackground release];
    [super dealloc];
}

@end
