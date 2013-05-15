//
//  DDShortUserTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTableViewCell.h"

@class DDShortUser;
@class DDImageView;

@interface DDShortUserTableViewCell : DDTableViewCell
{
}

@property(nonatomic, retain) DDShortUser *shortUser;

@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
//@property(nonatomic, retain) IBOutlet UILabel *labelLocation;
@property(nonatomic, retain) IBOutlet UIView *imageViewWrapper;
@property(nonatomic, retain) IBOutlet DDImageView *imageViewPoster;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewGender;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewCheckmark;

@end
