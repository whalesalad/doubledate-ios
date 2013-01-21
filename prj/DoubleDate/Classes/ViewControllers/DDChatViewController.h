//
//  DDChatViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 1/17/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@class DDEngagement;

@interface DDChatViewController : DDViewController
{
    BOOL keyboardExist_;
    NSMutableArray *messages_;
}

@property(nonatomic, assign) UIViewController *weakParentViewController;

@property(nonatomic, retain) DDEngagement *engagement;

@property(nonatomic, retain) IBOutlet UIView *mainView;
@property(nonatomic, retain) IBOutlet UIView *topBarView;
@property(nonatomic, retain) IBOutlet UIView *bottomBarView;
@property(nonatomic, retain) IBOutlet UITextView *textViewInput;
@property(nonatomic, retain) IBOutlet UIButton *buttonSend;
@property(nonatomic, retain) IBOutlet UITableView *tableView;

- (IBAction)sendTouched:(id)sender;

@end
