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
    NSMutableArray *doubleDatesAll_;
    NSMutableArray *doubleDatesMine_;
    DDRequestId requestDoubleDatesAll_;
    DDRequestId requestDoubleDatesMine_;
    DDDoubleDatesViewControllerMode mode_;
}

@property(nonatomic, assign) DDDoubleDatesViewControllerMode mode;

@property(nonatomic, retain) DDDoubleDateFilter *searchFilter;

+ (NSString*)filterCityName;

@end
