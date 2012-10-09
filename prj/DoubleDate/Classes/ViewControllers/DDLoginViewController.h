//
//  DDLoginViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 11.09.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@class DDAPIController;
@class DDWelcomeViewController;

@interface DDLoginViewController : DDViewController
{
}

@property(nonatomic, retain) IBOutlet UITextField *textFieldEmail;
@property(nonatomic, retain) IBOutlet UITextField *textFieldPassword;

- (IBAction)loginTouched:(id)sender;

@end
