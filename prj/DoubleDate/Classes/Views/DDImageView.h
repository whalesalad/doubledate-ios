//
//  DDImageView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "UIImageView+WebCache.h"

extern NSString *const DDImageViewUpdateNotification;

@interface DDImageView : UIImageView
{
    UIActivityIndicatorView *activityIndicatorView_;
}

- (void)reloadFromUrl:(NSURL*)url;

- (void)applyMask:(UIImage*)mask;

- (void)applyBorderStyling;

@end

@interface DDStyledImageView : UIImageView

- (void)reloadFromUrl:(NSURL*)url;

@end
