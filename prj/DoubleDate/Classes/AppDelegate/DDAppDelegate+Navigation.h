//
//  DDAppDelegate+Navigation.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAppDelegate.h"

@class DDUser;

@interface DDAppDelegate (Navigation)

- (void)loginUser:(DDUser*)user;
- (void)switchToWingsTab;
- (void)logout;

@end
