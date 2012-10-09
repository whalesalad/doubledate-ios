//
//  DDWingsViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 08.10.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@interface DDWingsViewController : DDViewController
{
    NSArray *friends_;
    NSArray *pendingInvitations_;
}

@property(nonatomic, retain) IBOutlet UITableView *tableView;

@end
