//
//  DDTagsView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDTagsView : UIView
{
}

@property(nonatomic, retain) UIImage *image;
@property(nonatomic, retain) UIFont *font;
@property(nonatomic, retain) NSArray *tags;
@property(nonatomic, retain) UIColor *textColor;
@property(nonatomic, assign) CGFloat gap;
@property(nonatomic, assign) UIEdgeInsets bubbleEdgeInsets;

- (void)customize;

@end
