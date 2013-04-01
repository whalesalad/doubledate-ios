//
//  DDAppDelegate+NavigationMenu.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAppDelegate.h"

@interface DDAppDelegate (NavigationMenu) <UINavigationControllerDelegate>

- (void)presentNavigationMenu;
- (void)dismissNavigationMenu;
- (BOOL)isNavigationMenuExist;

@end
