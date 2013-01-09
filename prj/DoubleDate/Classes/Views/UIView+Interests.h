//
//  UIView+Interests.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Interests)

- (CGFloat)applyInterests:(NSArray*)interests withBubbleImage:(UIImage*)bubbleImage custmomizationHandler:(void (^)(UILabel *bubbleLabel))custmomizationHandler;

@end
