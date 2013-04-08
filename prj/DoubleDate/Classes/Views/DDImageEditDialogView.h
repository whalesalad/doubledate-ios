//
//  DDImageEditDialogView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDImage;

@interface DDImageEditDialogView : UIView

- (id)initWithImage:(DDImage*)image inImageView:(UIImageView*)imageView ofView:(UIView*)view;

- (void)show;
- (void)dismiss;

@end
