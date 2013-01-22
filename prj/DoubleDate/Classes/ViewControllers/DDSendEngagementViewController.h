//
//  DDSendEngagementViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 05.12.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"
#import "DDSelectWingView.h"

@class DDDoubleDate;
@class DDEngagement;

@protocol DDSendEngagementViewControllerDelegate <NSObject>

- (void)sendEngagementViewControllerDidCancel;
- (void)sendEngagementViewControllerDidCreatedEngagement:(DDEngagement*)engagement;

@end

@interface DDSendEngagementViewController : DDViewController

@property(nonatomic, assign) id<DDSendEngagementViewControllerDelegate> delegate;

@property(nonatomic, retain) DDDoubleDate *doubleDate;

@property(nonatomic, retain) IBOutlet UITableView *tableView;

@property(nonatomic, retain) IBOutlet DDSelectWingView *selectWingView;

@property(nonatomic, retain) IBOutlet UIButton *buttonCancel;
@property(nonatomic, retain) IBOutlet UIButton *buttonSend;

- (IBAction)cancelTouched:(id)sender;
- (IBAction)sendTouched:(id)sender;

@end
