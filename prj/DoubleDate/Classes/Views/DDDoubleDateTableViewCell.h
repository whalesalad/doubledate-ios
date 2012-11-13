//
//  DDDoubleDateTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewCell.h"

@class DDImageView;
@class DDDoubleDate;

@interface DDDoubleDateTableViewCell : UITableViewCell
{
    UIImageView *imageViewBackgroundNormal_;
    UIImageView *imageViewBackgroundSelected_;
    UIImageView *imageViewPhotosBackground_;
    UIImageView *imageViewLocation_;
    DDImageView *imageViewUser_;
    DDImageView *imageViewWing_;
    UILabel *labelTitle_;
    UILabel *labelLocation_;
    UILabel *labelDistance_;
}

@property(nonatomic, retain) DDDoubleDate *doubleDate;

+ (CGFloat)height;

@end
