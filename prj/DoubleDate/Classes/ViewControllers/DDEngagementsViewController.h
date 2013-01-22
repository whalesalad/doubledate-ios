//
//  DDEngagementsViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 23.12.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewController.h"

@class DDDoubleDate;

@interface DDEngagementsViewController : DDTableViewController
{
    NSMutableArray *engagements_;
}

@property(nonatomic, assign) UIViewController *weakParentViewController;

@property(nonatomic, retain) DDDoubleDate *doubleDate;

@end
