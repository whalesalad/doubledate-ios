//
//  DDUserTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewCell.h"

@class DDFriendship;
@class DDShortUser;
@class DDPhotoView;

typedef enum
{
    DDUserTableViewCellTypeWings,
    DDUserTableViewCellTypeInvitations,
    DDUserTableViewCellTypeFacebook
} DDUserTableViewCellType;

@interface DDUserTableViewCell : DDTableViewCell
{
    UILabel *labelMain_;
    UILabel *labelDetails_;
    DDPhotoView *imageView_;
    UIImageView *imageViewGender_;
}

@property(nonatomic, assign) DDUserTableViewCellType type;

@property(nonatomic, retain) DDShortUser *shortUser;

@end
