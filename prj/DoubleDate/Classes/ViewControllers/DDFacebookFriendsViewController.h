//
//  DDFacebookFriendsViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTableViewController.h"

@interface DDFacebookFriendsViewController : DDTableViewController
{
    NSArray *friends_;
    NSMutableArray *friendsToInvite_;
}

@end

@protocol DDSelectFacebookFriendViewControllerDelegate <NSObject>

- (void)selectFacebookFriendViewControllerDidSelectWing:(DDShortUser*)user;

@end

@interface DDSelectFacebookFriendViewController : DDFacebookFriendsViewController

@property(nonatomic, assign) id<DDSelectFacebookFriendViewControllerDelegate> delegate;
@property(nonatomic, retain) NSArray *excludeUsers;

@end