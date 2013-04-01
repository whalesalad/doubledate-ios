//
//  DDUnlockAlertView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDUnlockAlertView.h"
#import "DDAPIObject.h"
#import "DDCoinsBar.h"
#import "DDAuthenticationController.h"
#import "DDAppDelegate.h"
#import "DDUser.h"
#import "DDViewController.h"
#import "DDBarButtonItem.h"
#import "DDTools.h"
#import "DDPurchaseViewController.h"
#import "DDAppDelegate+Purchase.h"
#import <QuartzCore/QuartzCore.h>

@interface DDUnlockAlertView () <DDUnlockAlertViewDelegate>

@property(nonatomic, retain) IBOutlet UILabel *labelPrice;
@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
@property(nonatomic, retain) IBOutlet UILabel *labelMessage;
@property(nonatomic, retain) IBOutlet UIButton *buttonCancel;
@property(nonatomic, retain) IBOutlet UIButton *buttonUnlock;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewBackground;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewCoinIcon;

- (IBAction)cancelTouched:(id)sender;
- (IBAction)unlockTouched:(id)sender;

@end

@implementation DDUnlockAlertView
{
    DDUnlockAlertView *core_;
}

@synthesize labelPrice;
@synthesize labelTitle;
@synthesize labelMessage;
@synthesize buttonCancel;
@synthesize buttonUnlock;
@synthesize imageViewBackground;
@synthesize imageViewCoinIcon;

@synthesize delegate;

@synthesize price=price_;
@synthesize title=title_;
@synthesize message=message_;
@synthesize unlockButtonText=unlockButtonText_;
@synthesize cancelButtonText=cancelButtonText_;

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.buttonCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self.buttonUnlock setTitle:NSLocalizedString(@"Yes! Unlock", nil) forState:UIControlStateNormal];
    self.unlockButtonText = [self.buttonUnlock titleForState:UIControlStateNormal];
    self.cancelButtonText = [self.buttonCancel titleForState:UIControlStateNormal];
    [self.buttonUnlock setBackgroundImage:[DDTools resizableImageFromImage:[self.buttonUnlock backgroundImageForState:UIControlStateNormal]] forState:UIControlStateNormal];
    [self.buttonCancel setBackgroundImage:[DDTools resizableImageFromImage:[self.buttonCancel backgroundImageForState:UIControlStateNormal]] forState:UIControlStateNormal];
    imageViewBackground.image = [DDTools resizableImageFromImage:imageViewBackground.image];
}

- (IBAction)cancelTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(unlockAlertViewDidCancel:)])
        [self.delegate unlockAlertViewDidCancel:self];
    [self dismiss];
}

- (IBAction)unlockTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(unlockAlertViewDidUnlock:)])
        [self.delegate unlockAlertViewDidUnlock:self];
    [self dismiss];
}

- (void)setPrice:(NSInteger)price
{
    price_ = price;
    [self.labelPrice setText:[NSString stringWithFormat:@"%d", price]];
}

- (NSInteger)price
{
    return price_;
}

- (void)setTitle:(NSString *)title
{
    if (title_ != title)
    {
        [title_ release];
        title_ = [title retain];
    }
    [self.labelTitle setText:title];
    [self setNeedsLayout];
}

- (NSString*)title
{
    return title_;
}

- (void)setMessage:(NSString *)message
{
    if (message_ != message)
    {
        [message_ release];
        message_ = [message retain];
    }
    CGFloat heightBefore = self.labelMessage.frame.size.height;
    self.labelMessage.text = message;
    CGFloat numberOfLines = [self.labelMessage sizeThatFits:self.labelMessage.bounds.size].width / self.labelMessage.frame.size.width;
    NSInteger numberOfLinesInt = numberOfLines<1?1:numberOfLines+1;
    self.labelMessage.numberOfLines = numberOfLinesInt;
    CGFloat heightAfter = [self.labelMessage sizeThatFits:self.labelMessage.bounds.size].height;
    CGFloat dh = heightAfter - heightBefore;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - dh / 2, self.frame.size.width, self.frame.size.height + dh / 2);
}

- (NSString*)message
{
    return message_;
}

- (void)setCancelButtonText:(NSString *)cancelButtonText
{
    if (cancelButtonText_ != cancelButtonText)
    {
        [cancelButtonText_ release];
        cancelButtonText_ = [cancelButtonText retain];
    }
    [[self buttonCancel] setTitle:cancelButtonText_ forState:UIControlStateNormal];
}

- (NSString*)cancelButtonText
{
    return cancelButtonText_;
}

- (void)setUnlockButtonText:(NSString *)unlockButtonText
{
    if (unlockButtonText_ != unlockButtonText)
    {
        [unlockButtonText_ release];
        unlockButtonText_ = [unlockButtonText retain];
    }
    [[self buttonUnlock] setTitle:unlockButtonText_ forState:UIControlStateNormal];
}

- (NSString*)unlockButtonText
{
    return unlockButtonText_;
}

- (void)show
{
    //make super
    [super show];
    
    //add core
    core_ = [[[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DDUnlockAlertView class]) owner:self options:nil] objectAtIndex:0] retain];
    core_.delegate = self;
    core_.price = self.price;
    core_.title = [self.title uppercaseString];
    core_.message = self.message;
    core_.center = self.bounceView.center;
    if (self.cancelButtonText)
        core_.cancelButtonText = self.cancelButtonText;
    if (self.unlockButtonText)
        core_.unlockButtonText = self.unlockButtonText;
    [self.bounceView addSubview:core_];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat gap = CGRectGetMinX(self.labelPrice.frame) - CGRectGetMaxX(self.imageViewCoinIcon.frame);
    CGFloat bothWidth = gap + self.imageViewCoinIcon.image.size.width + [self.labelPrice sizeThatFits:self.labelPrice.bounds.size].width;
    self.imageViewCoinIcon.frame = CGRectMake(self.frame.size.width/2 - bothWidth/2, self.imageViewCoinIcon.frame.origin.y, self.imageViewCoinIcon.frame.size.width, self.imageViewCoinIcon.frame.size.height);
    self.labelPrice.frame = CGRectMake(CGRectGetMaxX(self.imageViewCoinIcon.frame) + gap, self.labelPrice.frame.origin.y, self.labelPrice.frame.size.width, self.labelPrice.frame.size.height);
}

- (void)unlockAlertViewDidCancel:(DDUnlockAlertView*)sender
{
    if ([self.delegate respondsToSelector:@selector(unlockAlertViewDidCancel:)])
        [self.delegate unlockAlertViewDidCancel:self];
    [self dismiss];
}

- (void)unlockAlertViewDidUnlock:(DDUnlockAlertView*)sender
{
    if ([self.delegate respondsToSelector:@selector(unlockAlertViewDidUnlock:)])
        [self.delegate unlockAlertViewDidUnlock:self];
    [self dismiss];
}

- (void)dealloc
{
    [labelPrice release];
    [labelTitle release];
    [labelMessage release];
    [buttonCancel release];
    [buttonUnlock release];
    [imageViewBackground release];
    [imageViewCoinIcon release];
    [title_ release];
    [message_ release];
    [cancelButtonText_ release];
    [unlockButtonText_ release];
    [core_ release];
    [super dealloc];
}

@end

@interface DDUnlockAlertViewFullScreen () <DDUnlockAlertViewDelegate>

@end

@implementation DDUnlockAlertViewFullScreen
{
    DDCoinsBar *coinsBar_;
}

- (void)animationWillStart
{
    //add coins bar
    coinsBar_ = [[[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DDCoinsBar class]) owner:self options:nil] objectAtIndex:0] retain];
    coinsBar_.frame = CGRectMake(coinsBar_.frame.origin.x, [self bounds].size.height, coinsBar_.frame.size.width, coinsBar_.frame.size.height);
    [coinsBar_ setValue:[[[DDAuthenticationController currentUser] totalCoins] intValue]];
    [coinsBar_ addTarget:self action:@selector(moreCoinsTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:coinsBar_];
}

- (void)onAnimateShow
{
    coinsBar_.frame = CGRectMake(coinsBar_.frame.origin.x, [self bounds].size.height-coinsBar_.frame.size.height, coinsBar_.frame.size.width, coinsBar_.frame.size.height);
}

- (void)onAnimateHide
{
    coinsBar_.frame = CGRectMake(coinsBar_.frame.origin.x, [self bounds].size.height, coinsBar_.frame.size.width, coinsBar_.frame.size.height);
}

- (void)animationDidStop
{
    //remove coins bar
    [coinsBar_ removeFromSuperview];
    [coinsBar_ release];
    coinsBar_ = nil;
}

- (void)unlockAlertViewDidCancel:(DDUnlockAlertView*)sender
{
    if ([self.delegate respondsToSelector:@selector(unlockAlertViewDidCancel:)])
        [self.delegate unlockAlertViewDidCancel:self];
    [self dismiss];
}

- (void)unlockAlertViewDidUnlock:(DDUnlockAlertView*)sender
{
    if ([self.delegate respondsToSelector:@selector(unlockAlertViewDidUnlock:)])
        [self.delegate unlockAlertViewDidUnlock:self];
    [self dismiss];
}

- (void)moreCoinsTouched:(id)sender
{
    //remove self
    [self dismiss];
    
    //present purchase screen
    [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] presentPurchaseScreen];
}

- (void)dealloc
{
    [coinsBar_ release];
    [super dealloc];
}

@end
