//
//  DDMeViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDViewController.h"

@class DDUser;
@class DDStyledImageView;

@interface DDMeViewController : DDViewController
{
    DDRequestId updatePhotoRequest_;
    NSMutableArray *doubleDatesMine_;
    CGPoint contentOffset_;
}

@property(nonatomic, retain) DDUser *user;

@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UITextView *textView;
@property(nonatomic, retain) IBOutlet UIView *viewTop;
@property(nonatomic, retain) IBOutlet UIView *viewBottom;
@property(nonatomic, retain) IBOutlet DDStyledImageView *imageViewPoster;
@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
@property(nonatomic, retain) IBOutlet UILabel *labelLocation;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewGender;
@property(nonatomic, retain) IBOutlet UIButton *buttonEditProfile;
@property(nonatomic, retain) IBOutlet UIButton *buttonEditPhoto;
@property(nonatomic, retain) IBOutlet UIView *barYourDates;
@property(nonatomic, retain) IBOutlet UILabel *labelYourDates;
@property(nonatomic, retain) IBOutlet UIButton *buttonYourDates;
@property(nonatomic, retain) IBOutlet UILabel *viewNoDates;
@property(nonatomic, retain) IBOutlet UIButton *viewNoBio;

@end
