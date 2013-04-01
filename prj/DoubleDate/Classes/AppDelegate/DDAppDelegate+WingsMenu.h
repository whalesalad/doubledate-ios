//
//  DDAppDelegate+WingsMenu.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAppDelegate.h"
#import "DDChooseWingView.h"

@interface DDAppDelegate (WingsMenu) <DDChooseWingViewDelegate>

- (BOOL)presentWingsMenuWithDelegate:(id<DDChooseWingViewDelegate>)delegate excludedUsers:(NSArray*)excludedUsers;
- (BOOL)dismissWingsMenu;
- (BOOL)isWingsMenuExist;

@end
