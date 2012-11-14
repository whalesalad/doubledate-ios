//
//  DDDoubleDateFilterViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 14.11.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"
#import "DDSegmentedControl.h"

@interface DDDoubleDateFilterViewController : DDViewController

@property(nonatomic, retain) IBOutlet UILabel *labelSort;
@property(nonatomic, retain) IBOutlet UIView *viewSortContainer;
@property(nonatomic, retain) IBOutlet UILabel *labelWhen;
@property(nonatomic, retain) IBOutlet UIView *viewWhenContainer;

@end
