//
//  DDUserTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDFriendship;
@class DDShortUser;

typedef enum
{
    DDUserTableViewCellTypeWings,
    DDUserTableViewCellTypeInvitations,
    DDUserTableViewCellTypeFacebook
} DDUserTableViewCellType;

@interface DDUserTableViewCell : UITableViewCell
{
    UILabel *labelMain_;
    UILabel *labelDetails_;
    UIImageView *imageView_;
}

@property(nonatomic, assign) DDUserTableViewCellType type;

@property(nonatomic, retain) DDShortUser *shortUser;

@property(nonatomic, readonly) UILabel *labelMain;
@property(nonatomic, readonly) UILabel *labelDetails;
@property(nonatomic, readonly) UIImageView *imageView;

+ (CGFloat)height;

@end
