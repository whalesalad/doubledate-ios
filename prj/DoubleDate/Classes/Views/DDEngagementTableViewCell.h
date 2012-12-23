//
//  DDEngagementTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewCell.h"

@class DDEngagement;
@class DDPhotoView;

@interface DDEngagementTableViewCell : DDTableViewCell
{
    UILabel *labelTime_;
    UILabel *labelUser_;
    UILabel *labelWing_;
    UIImageView *imageViewGenderUser_;
    UIImageView *imageViewGenderWing_;
    DDPhotoView *photoUser_;
    DDPhotoView *photoWing_;
}

@property(nonatomic, retain) DDEngagement *engagement;

@end
