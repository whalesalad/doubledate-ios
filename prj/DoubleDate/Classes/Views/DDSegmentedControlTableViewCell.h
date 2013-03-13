//
//  DDSegmentedControlTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 3/13/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewCell.h"
#import "DDSegmentedControl.h"

@class DDSegmentedControlTableViewCell;

@protocol DDSegmentedControlTableViewCellDelegate <NSObject>

- (void)segmentedControlTableViewCellValueChanged:(DDSegmentedControlTableViewCell*)sender;

@end

@interface DDSegmentedControlTableViewCell : DDTableViewCell
{
    NSArray *items_;
    DDSegmentedControl *segmentedControl_;
    DDSegmentedControlStyle segmentedContolStyle_;
}

@property(nonatomic, assign) NSInteger selectedSegmentIndex;

@property(nonatomic, assign) id<DDSegmentedControlTableViewCellDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier items:(NSArray*)items segmentedContolStyle:(DDSegmentedControlStyle)segmentedContolStyle;

@end
