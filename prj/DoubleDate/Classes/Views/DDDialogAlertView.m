//
//  DDDialogAlertView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDialogAlertView.h"
#import "DDTools.h"

@interface DDDialogAlertView ()<DDCustomizableAlertViewDelegate>

@end

@implementation DDDialogAlertView
{
}

@synthesize dialogDelegate;

- (CGSize)coreSize
{
    for (UIView *v in [self.bounceView subviews])
    {
        if ([v isKindOfClass:[DDCustomizableAlertView class]])
            return v.bounds.size;
    }
    return CGSizeZero;
}

- (void)show
{
    //set delegate to self
    self.delegate = self;
    
    //make super
    [super show];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)confirmTouched:(id)sender
{
    [self dismiss];
    [self.dialogDelegate dialogAlertViewDidConfirm:self];
}

- (void)cancelTouched:(id)sender
{
    [self dismiss];
    [self.dialogDelegate dialogAlertViewDidCancel:self];
}

#pragma mark DDCustomizableAlertViewDelegate

- (NSInteger)heightForCustomAreaOfAlert:(DDCustomizableAlertView*)alert
{
    return 150;
}

- (UIView*)viewForCustomAreaOfAlert:(DDCustomizableAlertView *)alert
{
    //add thumbnail view
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unlock-btn-confirm.png"]] autorelease];
    imageView.backgroundColor = [UIColor blueColor];
    imageView.frame = CGRectMake(10, 0, [self coreSize].width-20, 150);
    return imageView;
}

- (NSInteger)heightForButtonsAreaOfAlert:(DDCustomizableAlertView*)alert
{
    return 100;
}

- (NSInteger)numberOfButtonsOfAlert:(DDCustomizableAlertView*)alert
{
    return 2;
}

- (UIButton*)buttonWithIndex:(NSInteger)index ofAlert:(DDCustomizableAlertView*)alert
{
    if (index == 0)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(20, 6, [self coreSize].width-40, 38);
        [button setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"unlock-btn-confirm.png"]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(confirmTouched:) forControlEvents:UIControlEventTouchUpInside];
        return button;
    }
    else if (index == 1)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(20, 100-6 - 38, [self coreSize].width-40, 38);
        [button setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"unlock-btn-cancel.png"]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(cancelTouched:) forControlEvents:UIControlEventTouchUpInside];
        return button;
    }
    return nil;
}

@end
