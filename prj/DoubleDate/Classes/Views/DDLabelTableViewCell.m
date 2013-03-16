//
//  DDLabelTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDLabelTableViewCell.h"
#import "DDLabel.h"

@implementation DDLabelTableViewCell

@synthesize label=label_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        label_ = [[DDLabel alloc] initWithFrame:CGRectZero];
        label_.backgroundColor = [UIColor clearColor];
        label_.contentMode = UIControlContentVerticalAlignmentCenter;
        label_.textColor = [UIColor whiteColor];
        [self.contentView addSubview:label_];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    label_.frame = CGRectMake(8, 0, self.contentView.frame.size.width-16, self.contentView.frame.size.height);
}

- (void)dealloc
{
    [label_ release];
    [super dealloc];
}

@end
