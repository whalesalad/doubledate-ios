//
//  DDIconTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDIconTableViewCell.h"
#import "DDTools.h"
#import "DDImageView.h"

@implementation DDIconTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        //add icon
        iconImageView_ = [[DDImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        iconImageView_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:iconImageView_];
        
        //add left label
        leftLabel_ = [[UITextField alloc] initWithFrame:CGRectZero];
        leftLabel_.userInteractionEnabled = NO;
        leftLabel_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        leftLabel_.textAlignment = NSTextAlignmentRight;
        leftLabel_.backgroundColor = [UIColor clearColor];
        DD_F_ICON_BUTTON_DETAILS(leftLabel_);
        leftLabel_.contentMode = UIViewContentModeBottom;
        [self.contentView addSubview:leftLabel_];
        
        //add right label
        rightLabelText_ = [[UITextField alloc] initWithFrame:CGRectZero];
        rightLabelText_.userInteractionEnabled = NO;
        rightLabelText_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        rightLabelText_.textAlignment = NSTextAlignmentLeft;
        rightLabelText_.backgroundColor = [UIColor clearColor];
        DD_F_ICON_BUTTON_TEXT(rightLabelText_);
        rightLabelText_.hidden = YES;
        [self.contentView addSubview:rightLabelText_];
        
        //add right label
        rightLabelPlaceholder_ = [[UITextField alloc] initWithFrame:CGRectZero];
        rightLabelPlaceholder_.userInteractionEnabled = NO;
        rightLabelPlaceholder_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        rightLabelPlaceholder_.textAlignment = NSTextAlignmentLeft;
        rightLabelPlaceholder_.backgroundColor = [UIColor clearColor];
        DD_F_ICON_BUTTON_PLACEHOLDER(rightLabelPlaceholder_);
        rightLabelPlaceholder_.hidden = NO;
        [self.contentView addSubview:rightLabelPlaceholder_];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    leftLabel_.frame = CGRectMake(0, 0, 55, self.contentView.frame.size.height);
    iconImageView_.center = CGPointMake(80, self.contentView.frame.size.height/2);
    rightLabelText_.frame = CGRectMake(105, 0, 180, self.contentView.frame.size.height);
    rightLabelPlaceholder_.frame = rightLabelText_.frame;
}

- (DDImageView*)iconImageView
{
    return iconImageView_;
}

- (void)setLeftText:(NSString *)leftText
{
    leftLabel_.text = leftText;
}

- (NSString*)leftText
{
    return leftLabel_.text;
}

- (void)setRightText:(NSString *)rightText
{
    rightLabelText_.text = rightText;
    rightLabelText_.hidden = [rightLabelText_.text length]==0;
    rightLabelPlaceholder_.hidden = !rightLabelText_.hidden;
}

- (NSString*)rightText
{
    return rightLabelText_.text;
}

- (void)setRightPlaceholder:(NSString *)rightPlaceholder
{
    rightLabelPlaceholder_.text = rightPlaceholder;
}

- (NSString*)rightPlaceholder
{
    return rightLabelPlaceholder_.text;
}

- (void)dealloc
{
    [iconImageView_ release];
    [leftLabel_ release];
    [rightLabelText_ release];
    [rightLabelPlaceholder_ release];
    [super dealloc];
}

@end
