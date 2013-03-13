//
//  DDSegmentedControlTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 3/13/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDSegmentedControlTableViewCell.h"

@implementation DDSegmentedControlTableViewCell

@synthesize selectedSegmentIndex;

- (void)updateSegmentedControl
{
    //remove previous segmented control
    [segmentedControl_ removeFromSuperview];
    [segmentedControl_ release];
    
    //add sort segmented control
    segmentedControl_ = [[DDSegmentedControl alloc] initWithItems:items_ style:segmentedContolStyle_];
    segmentedControl_.center = CGPointMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height/2);
    [segmentedControl_ addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:segmentedControl_];
    segmentedControl_.selectedSegmentIndex = self.selectedSegmentIndex;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier items:(NSArray*)items segmentedContolStyle:(DDSegmentedControlStyle)segmentedContolStyle
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        items_ = [items retain];
        segmentedContolStyle_ = segmentedContolStyle;
        self.selectedSegmentIndex = -1;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateSegmentedControl];
}

- (void)segmentedControlChanged:(DDSegmentedControl*)sender
{
    self.selectedSegmentIndex = sender.selectedSegmentIndex;
}

- (void)setSelectedSegmentIndex:(NSInteger)v
{
    segmentedControl_.selectedSegmentIndex = v;
}

- (NSInteger)selectedSegmentIndex
{
    return segmentedControl_.selectedSegmentIndex;
}

- (void)dealloc
{
    [items_ release];
    [segmentedControl_ release];
    [super dealloc];
}

@end
