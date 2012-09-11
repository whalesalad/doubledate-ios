//
//  DDCompleteRegistrationViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@class DDUser;
@class DDAPIController;

@interface DDCompleteRegistrationViewController : DDViewController
{
    DDAPIController *controller_;
}

@property(nonatomic, retain) DDUser *user;

@property(nonatomic, retain) IBOutlet UITextField *textFieldEmail;
@property(nonatomic, retain) IBOutlet UITextField *textFieldPassword;

- (IBAction)joinTouched:(id)sender;

@end
