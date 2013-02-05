//
//  DDAppDelegate+NavigationMenu.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAppDelegate.h"

@interface DDAppDelegate (NavigationMenu) <UINavigationControllerDelegate>

- (void)presentNavigationMenu;
- (void)dismissNavigationMenu;
- (BOOL)isNavigationMenuExist;

@end
