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

@interface DDDoubleDatesViewController : DDViewController
{
    NSMutableArray *doubleDates_;
}

@property(nonatomic, retain) IBOutlet UITableView *tableView;

@property(nonatomic, retain) DDUser *user;

@property(nonatomic, retain) DDDoubleDate *doubleDateToAdd;

@end
