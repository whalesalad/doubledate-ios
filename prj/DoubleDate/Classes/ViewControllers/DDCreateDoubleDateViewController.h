//
//  DDCreateDoubleDateViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDViewController.h"
#import "DDLocationController.h"
#import "DDTextView.h"
#import "DDUser.h"
#import "DDDoubleDatesViewController.h"

@interface DDCreateDoubleDateViewController : DDViewController
{
}

@property(nonatomic, retain) DDShortUser *wing;

@property(nonatomic, retain) IBOutlet UITableView *tableView;

@property(nonatomic, retain) IBOutlet UIButton *buttonCancel;
@property(nonatomic, retain) IBOutlet UIButton *buttonCreate;

@end
