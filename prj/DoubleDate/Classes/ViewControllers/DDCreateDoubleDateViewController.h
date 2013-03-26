//
//  DDCreateDoubleDateViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"
#import "DDLocationController.h"
#import "DDTextView.h"
#import "DDUser.h"
#import "DDDoubleDatesViewController.h"

@interface DDCreateDoubleDateViewController : DDViewController
{
}

@property(nonatomic, retain) DDDoubleDatesViewController *doubleDatesViewController;

@property(nonatomic, retain) IBOutlet UITableView *tableView;

@property(nonatomic, retain) IBOutlet UIButton *buttonCancel;
@property(nonatomic, retain) IBOutlet UIButton *buttonCreate;

+ (NSString*)titleForDDDoubleDateProperty:(NSString*)property;
+ (NSString*)titleForDDDay:(NSString*)day ddTime:(NSString*)time;

@end
