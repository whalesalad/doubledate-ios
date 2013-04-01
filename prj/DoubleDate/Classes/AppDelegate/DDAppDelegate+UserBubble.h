//
//  DDAppDelegate+UserBubble.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAppDelegate.h"

@class DDUser;

@interface DDAppDelegate (UserBubble) <UIScrollViewDelegate>

- (void)presentUserBubbleForUser:(DDUser*)user fromUsers:(NSArray*)users;

@end
