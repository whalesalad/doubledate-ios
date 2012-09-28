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

@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
@property(nonatomic, retain) IBOutlet DDImageView *imageViewPoster;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewOverlay;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewMale;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewFemale;
@property(nonatomic, retain) IBOutlet UILabel *labelAge;
@property(nonatomic, retain) IBOutlet UILabel *labelLocation;
@property(nonatomic, retain) IBOutlet UITextView *textViewBio;
@property(nonatomic, retain) IBOutlet DDTagsView *tagsViewInterests;

@end
