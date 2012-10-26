//
//  DDCreateDoubleDateViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"
#import "DDButton.h"

@interface DDCreateDoubleDateViewController : DDViewController

@property(nonatomic, retain) IBOutlet DDButton *buttonWing;

- (IBAction)wingTouched:(id)sender;

@end
