//
//  DDFacebookFriendsViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@interface DDFacebookFriendsViewController : DDViewController
{
    NSArray *friends_;
    BOOL friendsRequired_;
    NSMutableArray *friendsToInvite_;
}

@property(nonatomic, retain) IBOutlet UITableView *tableView;

@end
