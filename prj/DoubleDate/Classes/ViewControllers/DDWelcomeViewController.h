//
//  DDWelcomeViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@class DDAPIController;
@class DDUser;

@interface DDWelcomeViewController : DDViewController
{
    DDAPIController *controller_;
}

- (IBAction)facebookTouched:(id)sender;
- (IBAction)emailTouched:(id)sender;

- (void)startWithUser:(DDUser*)user;

@end
