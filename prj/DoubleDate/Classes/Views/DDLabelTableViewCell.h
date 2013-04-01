//
//  DDLabelTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTableViewCell.h"

@class DDLabel;

@interface DDLabelTableViewCell : DDTableViewCell
{
    DDLabel *label_;
}

@property(nonatomic, readonly) DDLabel *label;

@end
