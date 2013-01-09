//
//  DDMeViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@class DDUser;
@class DDImageView;
@class DDTagsView;

@interface DDMeViewController : DDViewController

@property(nonatomic, retain) DDUser *user;

@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
@property(nonatomic, retain) IBOutlet DDImageView *imageViewPoster;
@property(nonatomic, retain) IBOutlet UILabel *labelLocation;
@property(nonatomic, retain) IBOutlet UITextView *textViewBio;
@property(nonatomic, retain) IBOutlet UIView *viewInterests;
@property(nonatomic, retain) IBOutlet UILabel *labelInterests;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewGender;
@property(nonatomic, retain) IBOutlet UILabel *labelCoinsTitle;
@property(nonatomic, retain) IBOutlet UILabel *labelCoinsValue;
@property(nonatomic, retain) IBOutlet UILabel *labelKarmaTitle;
@property(nonatomic, retain) IBOutlet UILabel *labelKarmaValue;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewBioBackground;

@end
