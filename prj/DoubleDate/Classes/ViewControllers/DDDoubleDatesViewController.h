//
//  DDDoubleDatesViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewController.h"
#import "DDUser.h"
#import "DDDoubleDate.h"
#import "DDDoubleDateFilter.h"

typedef enum
{
    DDDoubleDatesViewControllerModeAll,
    DDDoubleDatesViewControllerModeMine
} DDDoubleDatesViewControllerMode;

@interface DDDoubleDatesViewController : DDTableViewController
{
    NSMutableArray *allDoubleDates_;
    NSMutableArray *mineDoubleDates_;
    DDDoubleDatesViewControllerMode mode_;
}

@property(nonatomic, retain) DDUser *user;

@property(nonatomic, retain) DDDoubleDateFilter *searchFilter;

@end
