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
@class DDCoinsBar;

@interface DDMeViewController : DDViewController
{
    DDRequestId updatePhotoRequest_;
}

@property(nonatomic, retain) DDUser *user;

@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
@property(nonatomic, retain) IBOutlet DDImageView *imageViewPoster;
@property(nonatomic, retain) IBOutlet UIView *blackBackgroundView;
@property(nonatomic, retain) IBOutlet UILabel *labelLocation;
@property(nonatomic, retain) IBOutlet UITextView *textViewBio;
@property(nonatomic, retain) IBOutlet UIView *textViewBioWrapper;
@property(nonatomic, retain) IBOutlet UIView *viewInterests;
@property(nonatomic, retain) IBOutlet UILabel *labelInterests;
@property(nonatomic, retain) IBOutlet UIView *interestsWrapper;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewGender;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewBioBackground;
@property(nonatomic, retain) IBOutlet UIView *coinBarContainer;

@end
