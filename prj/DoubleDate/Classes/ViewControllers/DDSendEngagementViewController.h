//
//  DDSendEngagementViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 05.12.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@class DDDoubleDate;

@interface DDSendEngagementViewController : DDViewController

@property(nonatomic, retain) DDDoubleDate *doubleDate;

@property(nonatomic, retain) IBOutlet UIButton *buttonCancel;
@property(nonatomic, retain) IBOutlet UIButton *buttonSend;

- (IBAction)cancelTouched:(id)sender;
- (IBAction)sendTouched:(id)sender;

@end
