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

@interface DDCreateDoubleDateViewController : DDViewController
{
    DDLocationController *locationController_;
}

@property(nonatomic, retain) IBOutlet DDButton *buttonWing;
@property(nonatomic, retain) IBOutlet DDButton *buttonLocation;

- (IBAction)wingTouched:(id)sender;
- (IBAction)locationTouched:(id)sender;

@end
