//
//  DDWingsViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 08.10.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewController.h"

@class DDUser;
@class DDShortUser;
@class DDWingsViewController;

@protocol DDWingsViewControllerDelegate <NSObject>
- (void)wingsViewController:(DDWingsViewController*)viewController didSelectUser:(DDShortUser*)user;
@end

@interface DDWingsViewController : DDTableViewController
{
    DDRequestId friendsRequest_;
    NSMutableArray *friends_;
    DDRequestId pendingInvitationsRequest_;
    NSMutableArray *pendingInvitations_;
}

@property(nonatomic, assign) id<DDWingsViewControllerDelegate> delegate;

@property(nonatomic, assign) BOOL isSelectingMode;

@property(nonatomic, retain) DDUser *user;

@end
