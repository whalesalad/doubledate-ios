//
//  DDIconTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDIconTableViewCell.h"
#import "DDTools.h"

@implementation DDIconTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        //add icon
        icon_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        icon_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:icon_];
        
        //add left label
        leftLabel_ = [[UITextField alloc] initWithFrame:CGRectZero];
        leftLabel_.userInteractionEnabled = NO;
        leftLabel_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        leftLabel_.textAlignment = UITextAlignmentRight;
        leftLabel_.backgroundColor = [UIColor clearColor];
        leftLabel_.font = [DDTools boldAvenirFontOfSize:12];
        leftLabel_.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.5f];
        leftLabel_.contentMode = UIViewContentModeBottom;
        [self.contentView addSubview:leftLabel_];
        
        //add right label
        rightLabelText_ = [[UITextField alloc] initWithFrame:CGRectZero];
        rightLabelText_.userInteractionEnabled = NO;
        rightLabelText_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        rightLabelText_.textAlignment = UITextAlignmentLeft;
        rightLabelText_.backgroundColor = [UIColor clearColor];
        rightLabelText_.font = [DDTools boldAvenirFontOfSize:16];
        rightLabelText_.hidden = YES;
        rightLabelText_.textColor = [UIColor whiteColor];
        [self.contentView addSubview:rightLabelText_];
        
        //add right label
        rightLabelPlaceholder_ = [[UITextField alloc] initWithFrame:CGRectZero];
        rightLabelPlaceholder_.userInteractionEnabled = NO;
        rightLabelPlaceholder_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        rightLabelPlaceholder_.textAlignment = UITextAlignmentLeft;
        rightLabelPlaceholder_.backgroundColor = [UIColor clearColor];
        rightLabelPlaceholder_.font = [DDTools boldAvenirFontOfSize:16];
        rightLabelPlaceholder_.hidden = NO;
        rightLabelPlaceholder_.textColor = [UIColor grayColor];
        [self.contentView addSubview:rightLabelPlaceholder_];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    icon_.center = CGPointMake(100, self.contentView.frame.size.height/2);
    leftLabel_.frame = CGRectMake(0, 0, 70, self.contentView.frame.size.height);
    rightLabelText_.frame = CGRectMake(130, 0, 160, self.contentView.frame.size.height);
    rightLabelPlaceholder_.frame = rightLabelText_.frame;
}

- (void)setImage:(UIImage *)image
{
    [icon_ setImage:image];
}

- (UIImage*)image
{
    return icon_.image;
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
    [icon_ release];
    [leftLabel_ release];
    [rightLabelText_ release];
    [rightLabelPlaceholder_ release];
    [super dealloc];
}

@end
