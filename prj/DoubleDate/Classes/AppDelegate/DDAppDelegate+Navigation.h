//
//  DDAppDelegate+Navigation.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAppDelegate.h"

@class DDUser;

@interface DDAppDelegate (Navigation)

- (void)loginUser:(DDUser*)user;
- (void)switchToWingsTab;
- (void)logout;

@end
