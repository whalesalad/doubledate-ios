//
//  DDImageView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDImageView : UIImageView
{
    NSURLConnection *connection_;
    UIActivityIndicatorView *activityIndicatorView_;
    NSMutableData *data_;
}

- (void)reloadFromUrl:(NSURL*)url;

- (void)applyMask:(UIImage*)mask;

@end
