//
//  DDChatViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 1/17/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@class DDEngagement;
@class DDDoubleDate;
@class DDImageView;
@class DDTextView;

@interface DDChatViewController : DDViewController
{
    BOOL keyboardExist_;
    NSMutableArray *messages_;
    NSMutableArray *shortUsers_;
    NSMutableArray *users_;
}

@property(nonatomic, assign) UIViewController *weakParentViewController;

@property(nonatomic, retain) DDEngagement *engagement;
@property(nonatomic, retain) DDDoubleDate *doubleDate;

@property(nonatomic, retain) IBOutlet UIView *mainView;
@property(nonatomic, retain) IBOutlet UIView *topBarView;
@property(nonatomic, retain) IBOutlet UIView *bottomBarView;
@property(nonatomic, retain) IBOutlet DDTextView *textViewInput;
@property(nonatomic, retain) IBOutlet UIButton *buttonSend;
@property(nonatomic, retain) IBOutlet UITableView *tableView;

@property(nonatomic, retain) IBOutlet DDImageView *imageViewUser1;
@property(nonatomic, retain) IBOutlet DDImageView *imageViewUser2;
@property(nonatomic, retain) IBOutlet DDImageView *imageViewUser3;
@property(nonatomic, retain) IBOutlet DDImageView *imageViewUser4;

@property(nonatomic, retain) IBOutlet UILabel *labelUser1;
@property(nonatomic, retain) IBOutlet UILabel *labelUser2;
@property(nonatomic, retain) IBOutlet UILabel *labelUser3;
@property(nonatomic, retain) IBOutlet UILabel *labelUser4;

@property(nonatomic, retain) IBOutlet UIImageView *imageViewChatBarBackground;

- (IBAction)sendTouched:(id)sender;

- (IBAction)user1Touched:(id)sender;
- (IBAction)user2Touched:(id)sender;
- (IBAction)user3Touched:(id)sender;
- (IBAction)user4Touched:(id)sender;

@end
