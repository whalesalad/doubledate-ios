//
//  UIView+Interests.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDUser;

@interface UIView (Interests)

- (CGFloat)applyInterestsForUser:(DDUser*)user bubbleImage:(UIImage*)bubbleImage matchedBubbleImage:(UIImage*)matchedBubbleImage custmomizationHandler:(void (^)(UILabel *bubbleLabel))custmomizationHandler;

@end
