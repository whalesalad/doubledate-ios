//
//  DDImageView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "UIImageView+WebCache.h"

@interface DDImageView : UIImageView
{
    UIActivityIndicatorView *activityIndicatorView_;
}

- (void)reloadFromUrl:(NSURL*)url;

- (void)applyMask:(UIImage*)mask;

@end
