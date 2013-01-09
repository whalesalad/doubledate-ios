//
//  DDWingTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewCell.h"

@class DDUser;
@class DDShortUser;
@class DDImageView;

@interface DDWingTableViewCell : DDTableViewCell
{
}

@property(nonatomic, retain) DDShortUser *shortUser;

@property(nonatomic, retain) IBOutlet DDImageView *imageViewPoster;
@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
@property(nonatomic, retain) IBOutlet UILabel *labelLocation;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewGender;

+ (NSString*)titleForShortUser:(DDShortUser*)user;
+ (NSString*)titleForUser:(DDUser*)user;

@end
