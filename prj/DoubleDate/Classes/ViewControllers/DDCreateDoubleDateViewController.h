//
//  DDCreateDoubleDateViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"
#import "DDButton.h"
#import "DDLocationController.h"
#import "DDTextView.h"
#import "DDUser.h"

@interface DDCreateDoubleDateViewController : DDViewController
{
    DDLocationController *locationController_;
}

@property(nonatomic, retain) IBOutlet DDButton *buttonWing;
@property(nonatomic, retain) IBOutlet DDButton *buttonLocation;
@property(nonatomic, retain) IBOutlet DDTextView *textViewDetails;
@property(nonatomic, retain) IBOutlet UITextField *textFieldTitle;

@property(nonatomic, retain) DDUser *user;

- (IBAction)wingTouched:(id)sender;
- (IBAction)locationTouched:(id)sender;
- (IBAction)freeAreaTouched:(id)sender;

@end
