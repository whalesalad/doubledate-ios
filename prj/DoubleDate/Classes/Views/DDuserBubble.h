//
//  DDUserBubble.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 12/24/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDUser;
@class DDUserBubbleViewController;

@interface DDUserBubble : UIView
{
    DDUserBubbleViewController *viewController_;
    CGFloat initialHeight_;
}

@property(nonatomic, readonly) CGFloat height;

@property(nonatomic, retain) NSArray *users;

@property(nonatomic, assign) NSInteger currentUserIndex;

@end
