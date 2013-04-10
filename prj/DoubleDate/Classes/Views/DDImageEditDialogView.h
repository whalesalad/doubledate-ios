//
//  DDImageEditDialogView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDImage;
@class DDImageEditDialogView;

@protocol DDImageEditDialogViewDelegate <NSObject>

- (void)imageEditDialogViewWillShow:(DDImageEditDialogView*)sender;
- (void)imageEditDialogViewDidShow:(DDImageEditDialogView*)sender;
- (void)imageEditDialogViewWillHide:(DDImageEditDialogView*)sender;
- (void)imageEditDialogViewDidHide:(DDImageEditDialogView*)sender;

- (void)imageEditDialogViewDidCancel:(DDImageEditDialogView*)sender;
- (void)imageEditDialogView:(DDImageEditDialogView*)sender didCutImage:(UIImage*)image inRect:(CGRect)rect;

@end

@interface DDImageEditDialogView : UIView

@property(nonatomic, assign) id<DDImageEditDialogViewDelegate> delegate;

- (id)initWithDDImage:(DDImage*)image inImageView:(UIImageView*)imageView;
- (id)initWithUIImage:(UIImage*)image inImageView:(UIImageView*)imageView;

- (void)show;
- (void)showInView:(UIView*)view;
- (void)dismiss;

@end
