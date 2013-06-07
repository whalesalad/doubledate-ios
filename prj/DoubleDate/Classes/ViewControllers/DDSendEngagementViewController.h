//
//  DDSendEngagementViewController.h
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

@protocol DDSendEngagementViewControllerDelegate <NSObject>

- (void)sendEngagementViewControllerDidCancel;
- (void)sendEngagementViewControllerDidCreatedEngagement:(DDEngagement*)engagement;

@end

@interface DDSendEngagementViewController : DDViewController
{
    NSInteger activateKeyboardCode_;
}

@property(nonatomic, assign) id<DDSendEngagementViewControllerDelegate> delegate;

@property(nonatomic, retain) DDDoubleDate *doubleDate;

@property(nonatomic, retain) IBOutlet UITableView *tableView;

@property(nonatomic, retain) IBOutlet UIButton *buttonCancel;
@property(nonatomic, retain) IBOutlet UIButton *buttonCreate;

@end
