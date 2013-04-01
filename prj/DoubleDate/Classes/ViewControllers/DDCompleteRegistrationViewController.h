//
//  DDCompleteRegistrationViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDViewController.h"

@class DDUser;
@class DDAPIController;

@interface DDCompleteRegistrationViewController : DDViewController
{
    DDUser *createdUser_;
    BOOL locationSent_;
    BOOL interestsSent_;
    BOOL posterSent_;
}

@property(nonatomic, retain) DDUser *user;

@property(nonatomic, retain) IBOutlet UITextField *textFieldEmail;
@property(nonatomic, retain) IBOutlet UITextField *textFieldPassword;

@end
