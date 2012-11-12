//
//  DDDoubleDatesViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"
#import "DDUser.h"
#import "DDDoubleDate.h"

typedef enum
{
    DDDoubleDatesViewControllerModeAll,
    DDDoubleDatesViewControllerModeMine
} DDDoubleDatesViewControllerMode;

@interface DDDoubleDatesViewController : DDViewController
{
    NSMutableArray *allDoubleDates_;
    NSMutableArray *mineDoubleDates_;
    DDDoubleDatesViewControllerMode mode_;
    NSString *searchTerm_;
}

@property(nonatomic, retain) IBOutlet UITableView *tableView;

@property(nonatomic, retain) DDUser *user;

@property(nonatomic, retain) DDDoubleDate *doubleDateToAdd;

@end
