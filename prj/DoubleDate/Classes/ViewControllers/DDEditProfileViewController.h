//
//  DDEditProfileViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 2/21/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@interface DDEditProfileViewController : DDViewController
{
    DDUser *user_;
}

- (id)initWithUser:(DDUser*)user;

@property(nonatomic, retain) IBOutlet UITableView *tableView;

@end
