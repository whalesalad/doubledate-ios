//
//  DDDoubleDateBubble.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 12/24/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDUser;
@class DDDoubleDateBubbleViewController;

@interface DDDoubleDateBubble : UIView
{
    DDDoubleDateBubbleViewController *viewController_;
    CGFloat initialHeight_;
}

@property(nonatomic, readonly) CGFloat height;

@property(nonatomic, retain) DDUser *user;

@end
