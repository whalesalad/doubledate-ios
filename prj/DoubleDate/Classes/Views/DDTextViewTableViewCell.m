//
//  DDTextViewTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTextViewTableViewCell.h"
#import "DDTextView.h"
#import "DDTools.h"

@implementation DDTextViewTableViewCell

@synthesize textView=textView_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        //add text view
        textView_ = [[DDTextView alloc] initWithFrame:CGRectZero];
        textView_.backgroundColor = [UIColor clearColor];
        textView_.textView.textColor = [UIColor whiteColor];
        DD_F_TEXT(textView_);
        [self.contentView addSubview:textView_];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    textView_.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
}

- (void)dealloc
{
    [textView_ release];
    [super dealloc];
}

@end
