//
//  DDUnlockAlertView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
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
#import <QuartzCore/QuartzCore.h>

@interface DDUnlockAlertView ()

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
    //save window
    UIWindow *window = [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] window];
    
    //set position
    self.center = CGPointMake(window.bounds.size.width/2, window.bounds.size.height/2);
    
    //animate
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    bounceAnimation.fillMode = kCAFillModeBoth;
    bounceAnimation.removedOnCompletion = YES;
    bounceAnimation.duration = 0.4;
    bounceAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 0.01f)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.1f)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 0.9f)],
                               [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    bounceAnimation.keyTimes = @[@0.0f, @0.5f, @0.75f, @1.0f];
    bounceAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.layer addAnimation:bounceAnimation forKey:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat gap = CGRectGetMinX(self.labelTitle.frame) - CGRectGetMaxX(self.imageViewCoinIcon.frame);
    CGFloat bothWidth = gap + self.imageViewCoinIcon.image.size.width + [self.labelTitle sizeThatFits:self.labelTitle.bounds.size].width;
    self.imageViewCoinIcon.frame = CGRectMake(self.frame.size.width/2 - bothWidth/2, self.imageViewCoinIcon.frame.origin.y, self.imageViewCoinIcon.frame.size.width, self.imageViewCoinIcon.frame.size.height);
    self.labelTitle.frame = CGRectMake(CGRectGetMaxX(self.imageViewCoinIcon.frame) + gap, self.labelTitle.frame.origin.y, self.labelTitle.frame.size.width, self.labelTitle.frame.size.height);
}

- (void)dismiss
{
    [self removeFromSuperview];
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
    [super dealloc];
}

@end

@interface DDUnlockAlertViewFullScreen () <DDUnlockAlertViewDelegate>

@end

@implementation DDUnlockAlertViewFullScreen

- (void)show
{
    //save window
    UIWindow *window = [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] window];
    
    //add view
    self.frame = [window bounds];
    [window addSubview:self];
    
    //fade screen
    UIView *fadeView = [[[UIView alloc] initWithFrame:[window bounds]] autorelease];
    fadeView.alpha = 0;
    fadeView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
    [self addSubview:fadeView];
    
    //show unlock
    DDUnlockAlertView *alertView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DDUnlockAlertView class]) owner:self options:nil] objectAtIndex:0];
    alertView.delegate = self;
    alertView.price = self.price;
    alertView.title = self.title;
    alertView.message = self.message;
    if (self.cancelButtonText)
        alertView.cancelButtonText = self.cancelButtonText;
    if (self.unlockButtonText)
        alertView.unlockButtonText = self.unlockButtonText;
    [alertView show];
    [self addSubview:alertView];
    
    //add coins bar
    DDCoinsBar *coinsBar = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DDCoinsBar class]) owner:self options:nil] objectAtIndex:0];
    coinsBar.frame = CGRectMake(coinsBar.frame.origin.x, [window bounds].size.height, coinsBar.frame.size.width, coinsBar.frame.size.height);
    [coinsBar setValue:[[[DDAuthenticationController currentUser] totalCoins] intValue]];
    [coinsBar addTarget:self action:@selector(moreCoinsTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:coinsBar];
    
    //animate
    [UIView animateWithDuration:0.3f animations:^{
        fadeView.alpha = 1;
        coinsBar.frame = CGRectMake(coinsBar.frame.origin.x, [window bounds].size.height-coinsBar.frame.size.height, coinsBar.frame.size.width, coinsBar.frame.size.height);
    }];
}

- (void)unlockAlertViewDidCancel:(DDUnlockAlertView*)sender
{
    if ([self.delegate respondsToSelector:@selector(unlockAlertViewDidCancel:)])
        [self.delegate unlockAlertViewDidCancel:self];
    [sender retain];
    [self dismiss];
    [sender release];
}

- (void)unlockAlertViewDidUnlock:(DDUnlockAlertView*)sender
{
    if ([self.delegate respondsToSelector:@selector(unlockAlertViewDidUnlock:)])
        [self.delegate unlockAlertViewDidUnlock:self];
    [sender retain];
    [self dismiss];
    [sender release];
}

- (void)moreCoinsTouched:(id)sender
{
    //remove self
    [self dismiss];
    
    //present view controller
    DDAppDelegate *appDelegate = (DDAppDelegate*)[[UIApplication sharedApplication] delegate];
    UIViewController *vc = [[[DDViewController alloc] init] autorelease];
    UINavigationController *nc = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    [[appDelegate topNavigationController] presentViewController:nc animated:YES completion:^{
    }];
    
    //set navigation item
    vc.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Close", nil) target:vc action:@selector(dismissViewController)];
}

@end
