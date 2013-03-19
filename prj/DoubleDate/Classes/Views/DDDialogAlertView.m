//
//  DDDialogAlertView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDialogAlertView.h"
#import "DDTools.h"
#import "DDDialog.h"
#import "DDImageView.h"

@interface DDDialogAlertView ()<DDCustomizableAlertViewDelegate>

@end

@implementation DDDialogAlertView
{
}

@synthesize dialogDelegate;
@synthesize imageUrl;

- (id)initWithDialog:(DDDialog*)dialog
{
    if ((self = [super init]))
    {
        dialog_ = [dialog retain];
    }
    return self;
}

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
    
    //customize self
    self.message = dialog_.description;
    self.title = dialog_.upperText;
    self.coins = [dialog_.coins intValue];
    
    //make super
    [super show];
}

- (void)dealloc
{
    [dialog_ release];
    [imageUrl release];
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

- (BOOL)containsAllButtons
{
    return [dialog_.confirmText length] > 0;
}

#pragma mark DDCustomizableAlertViewDelegate

- (NSInteger)heightForCustomAreaOfAlert:(DDCustomizableAlertView*)alert
{
    if (self.imageUrl)
        return 150;
    return 0;
}

- (UIView*)viewForCustomAreaOfAlert:(DDCustomizableAlertView *)alert
{
    if (self.imageUrl)
    {
        //add thumbnail view
        DDImageView *imageView = [[[DDImageView alloc] init] autorelease];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.frame = CGRectMake(10, 0, [self coreSize].width-20, 150);
        [imageView reloadFromUrl:self.imageUrl];
        return imageView;
    }
    return nil;
}

- (NSInteger)heightForButtonsAreaOfAlert:(DDCustomizableAlertView*)alert
{
    return [self containsAllButtons]?100:50;
}

- (NSInteger)numberOfButtonsOfAlert:(DDCustomizableAlertView*)alert
{
    return [self containsAllButtons]?2:1;
}

- (UIButton*)buttonWithIndex:(NSInteger)index ofAlert:(DDCustomizableAlertView*)alert
{
    //save dismiss flag
    BOOL dismissButton = ![self containsAllButtons] || (index == 1);
    
    //add button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, 8 + 50 * index, [self coreSize].width-40, 38);
    
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];

#warning none of these text color changes seem to work
//    button.titleLabel.textColor = [UIColor colorWithRed:43.0f/255.0f green:42.0f/255.0f blue:43.0f/255.0f alpha:1.0f];
    button.titleLabel.textColor = [UIColor redColor];
    
//    [button setFontOfName:@"HelveticaNeue-Bold" fontSize:17 textColor:[UIColor colorWithRed:43.0f/255.0f green:42.0f/255.0f blue:43.0f/255.0f alpha:1.0f] shadowOffset:CGSizeMake(0, 1) shadowColor:[UIColor blackColor]];
    [button setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:dismissButton?@"unlock-btn-cancel.png":@"unlock-btn-confirm.png"]] forState:UIControlStateNormal];
    [button setTitle:dismissButton?dialog_.dismissText:dialog_.confirmText forState:UIControlStateNormal];
    [button addTarget:self action:dismissButton?@selector(cancelTouched:):@selector(confirmTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

@end
