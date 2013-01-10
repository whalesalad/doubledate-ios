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
@class DDPlacemark;

@interface DDDoubleDateTableViewCell : DDTableViewCell
{
}

@property(nonatomic, retain) DDDoubleDate *doubleDate;

@property(nonatomic, retain) IBOutlet DDImageView *imageViewUser;
@property(nonatomic, retain) IBOutlet DDImageView *imageViewWing;
@property(nonatomic, retain) IBOutlet UIView *viewEffects;
@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
@property(nonatomic, retain) IBOutlet UILabel *labelLocation;

+ (NSString*)detailedTitleForLocation:(DDPlacemark*)location;

@end
