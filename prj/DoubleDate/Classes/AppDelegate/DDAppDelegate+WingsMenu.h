//
//  DDAppDelegate+WingsMenu.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAppDelegate.h"
#import "DDChooseWingView.h"

@interface DDAppDelegate (WingsMenu) <DDChooseWingViewDelegate>

- (BOOL)presentWingsMenuWithDelegate:(id<DDChooseWingViewDelegate>)delegate excludedUsers:(NSArray*)excludedUsers;
- (BOOL)dismissWingsMenu;
- (BOOL)isWingsMenuExist;

@end
