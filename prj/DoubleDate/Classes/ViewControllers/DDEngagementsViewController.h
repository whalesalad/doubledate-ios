//
//  DDEngagementsViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 23.12.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewController.h"

@class DDDoubleDate;
@class DDEngagement;

@interface DDEngagementsViewController : DDTableViewController
{
    NSMutableArray *engagements_;
    DDEngagement *selectedEngagement_;
}

@property(nonatomic, assign) UIViewController *weakParentViewController;

- (void)applyNoDataLabelStyle:(UILabel*)label;

- (void)removeEngagement:(DDEngagement*)engagement;

@end
