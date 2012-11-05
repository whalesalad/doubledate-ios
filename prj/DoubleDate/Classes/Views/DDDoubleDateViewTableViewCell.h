//
//  DDDoubleDateViewTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewCell.h"

@class DDImageView;
@class DDDoubleDate;

@interface DDDoubleDateViewTableViewCell : DDTableViewCell
{
    UIImageView *imageViewPhotosBackground_;
    DDImageView *imageViewUser_;
    DDImageView *imageViewWing_;
    UIImageView *imageViewArrow_;
    UILabel *labelTitle_;
    UILabel *labelLocation_;
    UILabel *labelDistance_;
}

@property(nonatomic, retain) DDDoubleDate *doubleDate;

@end
