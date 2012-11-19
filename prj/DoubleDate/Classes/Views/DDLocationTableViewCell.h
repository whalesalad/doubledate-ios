//
//  DDLocationTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewCell.h"

@class DDPlacemark;

@interface DDLocationTableViewCell : DDTableViewCell
{
}

@property(nonatomic, retain) DDPlacemark *location;

+ (NSString*)mainTitleForLocation:(DDPlacemark*)location;
+ (NSString*)detailedTitleForLocation:(DDPlacemark*)location;

@end
