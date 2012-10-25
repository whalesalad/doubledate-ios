//
//  DDWingsViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 08.10.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@class DDUser;
@class DDShortUser;
@class DDWingsViewController;

@protocol DDWingsViewControllerDelegate <NSObject>
- (void)wingsViewController:(DDWingsViewController*)viewController didSelectUser:(DDShortUser*)user;
@end

@interface DDWingsViewController : DDViewController
{
    NSMutableArray *friends_;
    NSMutableArray *pendingInvitations_;
}

@property(nonatomic, assign) id<DDWingsViewControllerDelegate> delegate;

@property(nonatomic, assign) BOOL isSelectingMode;

@property(nonatomic, retain) IBOutlet UITableView *tableView;

@property(nonatomic, retain) DDUser *user;

@end
