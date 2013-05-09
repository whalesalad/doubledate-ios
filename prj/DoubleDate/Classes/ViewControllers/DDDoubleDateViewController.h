//
//  DDDoubleDateViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 11/16/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDViewController.h"

@class DDDoubleDate;
@class DDWEImageView;
@class DDUser;
@class DDImageView;

@interface DDDoubleDateViewController : DDViewController
{
    BOOL messageSent_;
    BOOL messageSentAnimated_;
}

@property(nonatomic, retain) DDDoubleDate *doubleDate;

@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) IBOutlet UIView *bottomView;

@property(nonatomic, retain) IBOutlet DDImageView *imageViewLeft;
@property(nonatomic, retain) IBOutlet DDImageView *imageViewRight;

@property(nonatomic, retain) IBOutlet UIButton *buttonInterested;

@property(nonatomic, retain) IBOutlet UIView *scrollTopView;
@property(nonatomic, retain) IBOutlet UIView *scrollCenterView;
@property(nonatomic, retain) IBOutlet UIView *scrollBottomView;

@property(nonatomic, retain) IBOutlet UILabel *labelLocationMain;
@property(nonatomic, retain) IBOutlet UILabel *labelLocationDetailed;

@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
@property(nonatomic, retain) IBOutlet UITextView *textView;

@property(nonatomic, retain) IBOutlet UILabel *labelLeftUser;
@property(nonatomic, retain) IBOutlet UILabel *labelRightUser;

@property(nonatomic, retain) IBOutlet UIImageView *imageViewLeftUserGender;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewRightUserGender;

@property(nonatomic, retain) IBOutlet UIView *leftView;
@property(nonatomic, retain) IBOutlet UIView *rightView;

@property(nonatomic, retain) IBOutlet UILabel *labelInterested;

@property(nonatomic, retain) IBOutlet UIView *sentView;
@property(nonatomic, retain) IBOutlet UIView *sentViewAnimation;
@property(nonatomic, retain) IBOutlet UILabel *labelMessageSent;

- (IBAction)leftUserTouched:(id)sender;
- (IBAction)rightUserTouched:(id)sender;
- (IBAction)interestedTouched:(id)sender;
- (IBAction)closeWarningTouched:(id)sender;

@end
