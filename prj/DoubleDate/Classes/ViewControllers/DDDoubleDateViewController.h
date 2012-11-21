//
//  DDDoubleDateViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 11/16/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@class DDDoubleDate;
@class DDImageView;

@interface DDDoubleDateViewController : DDViewController
{
    BOOL leftUserRequested_;
}

@property(nonatomic, retain) DDDoubleDate *doubleDate;

@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property(nonatomic, retain) IBOutlet UILabel *labelLocationMain;
@property(nonatomic, retain) IBOutlet UILabel *labelLocationDetailed;
@property(nonatomic, retain) IBOutlet UILabel *labelDayTime;

@property(nonatomic, retain) IBOutlet UIView *containerTextView;
@property(nonatomic, retain) IBOutlet UIImageView *containerTopImageView;
@property(nonatomic, retain) IBOutlet UIImageView *containerBottomImageView;

@property(nonatomic, retain) IBOutlet UITextView *textView;

@property(nonatomic, retain) IBOutlet UIView *containerPhotos;

@property(nonatomic, retain) IBOutlet DDImageView *imageViewUserLeft;
@property(nonatomic, retain) IBOutlet DDImageView *imageViewUserRight;

@property(nonatomic, retain) IBOutlet UIImageView *imageViewUserLeftHighlighted;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewUserRightHighlighted;

@property(nonatomic, retain) IBOutlet UIImageView *imageViewFade;

@property(nonatomic, retain) IBOutlet UILabel *labelUserLeft;
@property(nonatomic, retain) IBOutlet UILabel *labelUserRight;

- (IBAction)leftUserTouched:(id)sender;
- (IBAction)rightUserTouched:(id)sender;

@end
