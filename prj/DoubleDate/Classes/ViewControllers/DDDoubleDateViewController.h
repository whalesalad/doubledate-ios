//
//  DDDoubleDateViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 11/16/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@class DDDoubleDate;
@class DDWEImageView;
@class DDUser;
@class DDPhotoView;
@class DDToggleButton;

@interface DDDoubleDateViewController : DDViewController
{
    BOOL initialValueInitialized_;
    CGPoint initialTextViewContentOffset_;
    CGSize initialScrollViewContentSize_;
    CGRect initialContainerTextViewFrame_;
    CGPoint initialContainerPhotosCenter_;
    int lastMode_;
}

@property(nonatomic, retain) DDDoubleDate *doubleDate;

@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property(nonatomic, retain) IBOutlet UIView *containerHeader;
@property(nonatomic, retain) IBOutlet UILabel *labelLocationMain;
@property(nonatomic, retain) IBOutlet UILabel *labelLocationDetailed;
@property(nonatomic, retain) IBOutlet UILabel *labelDayTime;

@property(nonatomic, retain) IBOutlet UIView *containerTextView;
@property(nonatomic, retain) IBOutlet UIImageView *containerTopImageView;
@property(nonatomic, retain) IBOutlet UIImageView *containerBottomImageView;

@property(nonatomic, retain) IBOutlet UITextView *textView;

@property(nonatomic, retain) IBOutlet UIView *containerPhotos;

@property(nonatomic, retain) IBOutlet UIImageView *imageViewFade;

@property(nonatomic, retain) IBOutlet UIButton *buttonInterested;

@property(nonatomic, retain) IBOutlet DDToggleButton *buttonInfo;
@property(nonatomic, retain) IBOutlet DDToggleButton *buttonIncoming;

@property(nonatomic, retain) IBOutlet UIView *bottomView;
@property(nonatomic, retain) IBOutlet UIView *centerView;
@property(nonatomic, retain) IBOutlet UIView *topView;

@property(nonatomic, retain) IBOutlet DDPhotoView *photoViewLeft;
@property(nonatomic, retain) IBOutlet DDPhotoView *photoViewRight;

@property(nonatomic, retain) IBOutlet UIView *viewInfo;
@property(nonatomic, retain) IBOutlet UIView *viewIncoming;

- (IBAction)leftUserTouched:(id)sender;
- (IBAction)rightUserTouched:(id)sender;
- (IBAction)interestedTouched:(id)sender;
- (IBAction)tabTouched:(id)sender;

@end
