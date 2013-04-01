//
//  DDTextFieldTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTextFieldTableViewCell.h"
#import "DDTextField.h"
#import "DDTools.h"

@implementation DDTextFieldTableViewCell

@synthesize textField=textField_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        //add text field
        textField_ = [[DDTextField alloc] initWithFrame:CGRectZero];
        textField_.backgroundColor = [UIColor clearColor];
        textField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField_.textColor = [UIColor whiteColor];
        [self.contentView addSubview:textField_];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    textField_.frame = CGRectMake(8, 0, self.contentView.frame.size.width-16, self.contentView.frame.size.height);
}

- (void)dealloc
{
    [textField_ release];
    [super dealloc];
}

@end
