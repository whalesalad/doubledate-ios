//
//  DDInterestsViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/10/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"
#import "TITokenField.h"

@class DDUser;
@class DDAPIController;

@interface DDInterestsViewController : DDViewController
{
    DDAPIController *controller_;
    BOOL interestsRequested_;
    DDUser *createdUser_;
    BOOL locationSent_;
    BOOL interestsSent_;
    BOOL posterSent_;
}

@property(nonatomic, retain) DDUser *user;

@property (nonatomic, retain) IBOutlet TITokenFieldView *tokenFieldViewInterests;

@end
