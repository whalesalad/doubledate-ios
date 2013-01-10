//
//  DDInvitationTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDInvitationTableViewCell.h"
#import "DDTools.h"
#import <QuartzCore/QuartzCore.h>

@implementation DDInvitationTableViewCell

@synthesize buttonAccept;
@synthesize buttonDeny;

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self.buttonAccept setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"accept-button.png"]] forState:UIControlStateNormal];
    [self.buttonDeny setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"deny-button.png"]] forState:UIControlStateNormal];

    [self applyShadowToButton:self.buttonAccept];
    [self applyShadowToButton:self.buttonDeny];
}

- (void)applyShadowToButton:(UIButton *)button {
    button.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    button.titleLabel.layer.shadowOffset = CGSizeMake(0, -1);
    button.titleLabel.layer.shadowRadius = 0;
    button.titleLabel.layer.shadowOpacity = 0.2f;
}

- (void)dealloc
{
    [buttonAccept release];
    [buttonDeny release];
    [super dealloc];
}

@end
