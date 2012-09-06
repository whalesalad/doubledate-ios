//
//  DDWelcomeViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@class DDAPIController;

@interface DDWelcomeViewController : DDViewController
{
    DDAPIController *controller_;
}

- (IBAction)signupTouched:(id)sender;
- (IBAction)loginTouched:(id)sender;

@end
