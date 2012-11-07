//
//  DDLocationTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewCell.h"

@class DDLocation;

@interface DDLocationTableViewCell : DDTableViewCell
{
}

@property(nonatomic, retain) DDLocation *location;

+ (CGFloat)height;

@end
