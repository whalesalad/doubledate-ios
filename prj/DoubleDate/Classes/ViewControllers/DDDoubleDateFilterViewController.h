//
//  DDDoubleDateFilterViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 14.11.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewController.h"
#import "DDDoubleDateFilterViewController.h"
#import "DDSegmentedControl.h"

@class DDDoubleDateFilter;

@protocol DDDoubleDateFilterViewControllerDelegate <NSObject>

- (void)doubleDateFilterViewControllerDidCancel;
- (void)doubleDateFilterViewControllerDidAppliedFilter:(DDDoubleDateFilter*)filter;

@end

@interface DDDoubleDateFilterViewController : DDTableViewController
{
    DDDoubleDateFilter *filter_;
}

@property(nonatomic, assign) id<DDDoubleDateFilterViewControllerDelegate> delegate;

- (id)initWithFilter:(DDDoubleDateFilter*)filter;

@end
