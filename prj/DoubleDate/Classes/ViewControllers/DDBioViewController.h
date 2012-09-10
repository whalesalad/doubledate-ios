//
//  DDBioViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/10/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@class DDUser;

@interface DDBioViewController : DDViewController

@property(nonatomic, retain) DDUser *user;

@property(nonatomic, retain) IBOutlet UITextView *textViewBio;

@end
