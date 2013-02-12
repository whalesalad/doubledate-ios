//
//  DDNotificationTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewCell.h"

@class DDImageView;
@class DDNotification;

@interface DDNotificationTableViewCell : DDTableViewCell
{
}

@property(nonatomic, retain) DDNotification *notification;

@property(nonatomic, retain) IBOutlet DDImageView *imageViewUser;
@property(nonatomic, retain) IBOutlet DDImageView *imageViewWing;
@property(nonatomic, retain) IBOutlet UIView *viewEffects;
@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
@property(nonatomic, retain) IBOutlet UILabel *labelDetailed;
@property(nonatomic, retain) IBOutlet UIView *viewImagesContainer;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewBadge;

+ (CGFloat)heightForNotification:(DDNotification*)notification;

@end
