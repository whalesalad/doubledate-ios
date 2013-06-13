//
//  DDNotificationTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTableViewCell.h"

@class DDImageView;
@class DDNotification;

@interface DDNotificationTableViewCell : DDTableViewCell
{
}

@property(nonatomic, retain) DDNotification *notification;

@property(nonatomic, retain) IBOutlet DDImageView *imageView;
@property(nonatomic, retain) IBOutlet UITextView *textViewContent;
@property(nonatomic, retain) IBOutlet UIImageView *unreadIndicatorView;

+ (CGFloat)heightForNotification:(DDNotification*)notification;

- (void)drawInnerGradient;

@end
