//
//  DDChooseWingTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTableViewCell.h"

@class DDShortUser;

@interface DDChooseWingTableViewCell : DDTableViewCell
{
    DDShortUser *shortUser;
}

@property(nonatomic, retain) IBOutlet DDImageView *imageViewUser;
@property(nonatomic, retain) IBOutlet UILabel *labelName;
@property(nonatomic, retain) IBOutlet UIView *wrapperView;

@property(nonatomic, retain) DDShortUser *shortUser;

@end
