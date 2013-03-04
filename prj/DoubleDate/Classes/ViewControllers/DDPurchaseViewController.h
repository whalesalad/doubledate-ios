//
//  DDPurchaseViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 03.03.13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@interface DDPurchaseViewController : DDViewController

@property(nonatomic, retain) NSArray *products;

@property(nonatomic, retain) IBOutlet UITableView *tableView;

@end
