//
//  UIImage+DD.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (DD)

- (UIImage*)fixOrientation;

- (UIImage*)imageOfSize:(CGSize)size;

- (UIImage*)blurImage;

- (UIImage*)resizableImage;

- (UIImage*)cutImageWithRect:(CGRect)rect;

+ (UIImage*)clearImage;

+ (UIImage*)clearImageOfSize:(CGSize)size;

@end