//
//  DDAppDelegate+UserBubble.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAppDelegate.h"

@class DDUser;

@interface DDAppDelegate (UserBubble) <UIScrollViewDelegate>

- (void)presentUserBubbleForUser:(DDUser*)user fromUsers:(NSArray*)users;

@end
