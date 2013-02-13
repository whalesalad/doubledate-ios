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

@property(nonatomic, retain) IBOutlet DDImageView *imageViewLeft;
@property(nonatomic, retain) IBOutlet DDImageView *imageViewRight;
@property(nonatomic, retain) IBOutlet DDImageView *imageViewFull;
@property(nonatomic, retain) IBOutlet UITextView *textViewContent;
@property(nonatomic, retain) IBOutlet UIView *viewImagesContainer;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewBadge;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewGlow;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewBackground;
@property(nonatomic, retain) IBOutlet UIView *wrapperView;

+ (CGFloat)heightForNotification:(DDNotification*)notification;

@end
