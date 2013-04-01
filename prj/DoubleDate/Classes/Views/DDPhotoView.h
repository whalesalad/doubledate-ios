//
//  DDUserPhotoView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDImageView;
@class DDImage;

@interface DDPhotoView : UIControl
{
    DDImageView *imageView_;
    UIImageView *highlightImageView_;
    UIImageView *overlayImageView_;
    UILabel *label_;
    UIButton *button_;
    NSMutableArray *internal_;
}

@property(nonatomic, readonly) UILabel *label;
@property(nonatomic, readonly) UIImageView *highlightImageView;

@property(nonatomic, retain) NSString *text;

- (void)applyImage:(DDImage*)image;

@end
