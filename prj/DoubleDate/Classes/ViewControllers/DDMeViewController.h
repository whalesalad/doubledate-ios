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

@interface DDMeViewController : DDViewController

@property (nonatomic, retain) DDUser *user;

@property (nonatomic, retain) IBOutlet UILabel *labelTitle;
@property (nonatomic, retain) IBOutlet DDImageView *imageViewPoster;

@end
