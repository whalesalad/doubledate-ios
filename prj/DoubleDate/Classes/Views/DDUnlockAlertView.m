//
//  DDUnlockAlertView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDUnlockAlertView.h"

@interface DDUnlockAlertView ()

@property(nonatomic, retain) IBOutlet UILabel *labelPrice;
@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
@property(nonatomic, retain) IBOutlet UILabel *labelMessage;

- (IBAction)cancelTouched:(id)sender;
- (IBAction)unlockTouched:(id)sender;

@end

@implementation DDUnlockAlertView

@synthesize labelPrice;
@synthesize labelTitle;
@synthesize labelMessage;

@synthesize delegate;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (IBAction)cancelTouched:(id)sender
{
    [self.delegate unlockAlertViewDidCancel:self];
}

- (IBAction)unlockTouched:(id)sender
{
    [self.delegate unlockAlertViewDidUnlock:self];
}

- (void)setPrice:(NSInteger)price
{
    [self.labelPrice setText:[NSString stringWithFormat:@"%d", price]];
}

- (NSInteger)price
{
    return [[self.labelPrice text] intValue];
}

- (void)setTitle:(NSString *)title
{
    [self.labelTitle setText:title];
}

- (NSString*)title
{
    return self.labelTitle.text;
}

- (void)setMessage:(NSString *)message
{
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
    return self.labelMessage.text;
}

- (void)dealloc
{
    [labelPrice release];
    [labelTitle release];
    [labelMessage release];
    [super dealloc];
}

@end
