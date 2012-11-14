//
//  DDDoubleDateFilterViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 14.11.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"
#import "DDSegmentedControl.h"

@class DDDoubleDateFilter;

@protocol DDDoubleDateFilterViewControllerDelegate <NSObject>

- (void)doubleDateFilterViewControllerDidCancel;
- (void)doubleDateFilterViewControllerDidAppliedFilter:(DDDoubleDateFilter*)filter;

@end

@interface DDDoubleDateFilterViewController : DDViewController
{
    DDDoubleDateFilter *filter_;
    NSMutableArray *distances_;
    NSMutableArray *minAges_;
    NSMutableArray *maxAges_;
    UITextField *textFieldDistance_;
    UITextField *textFieldMinAge_;
    UITextField *textFieldMaxAge_;
}

@property(nonatomic, assign) id<DDDoubleDateFilterViewControllerDelegate> delegate;

@property(nonatomic, retain) IBOutlet UILabel *labelSort;
@property(nonatomic, retain) IBOutlet UIView *viewSortContainer;
@property(nonatomic, retain) IBOutlet UILabel *labelWhen;
@property(nonatomic, retain) IBOutlet UIView *viewWhenContainer;
@property(nonatomic, retain) IBOutlet UILabel *labelDistance;
@property(nonatomic, retain) IBOutlet UIView *viewDistanceContainer;
@property(nonatomic, retain) IBOutlet UILabel *labelMinAge;
@property(nonatomic, retain) IBOutlet UIView *viewMinAgeContainer;
@property(nonatomic, retain) IBOutlet UILabel *labelMaxAge;
@property(nonatomic, retain) IBOutlet UIView *viewMaxAgeContainer;

- (id)initWithFilter:(DDDoubleDateFilter*)filter;

@end
