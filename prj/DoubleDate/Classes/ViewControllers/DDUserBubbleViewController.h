//
//  DDUserBubbleViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 12/24/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDImageView;

@interface DDUserBubbleViewController : UIViewController

@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
@property(nonatomic, retain) IBOutlet UILabel *labelLocation;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewGender;
@property(nonatomic, retain) IBOutlet DDImageView *photoView;
@property(nonatomic, retain) IBOutlet UITextView *textView;
@property(nonatomic, retain) IBOutlet UIView *viewInterests;
@property(nonatomic, retain) IBOutlet UIView *viewMain;
@property(nonatomic, retain) IBOutlet UILabel *labelIceBreakers;
@property(nonatomic, retain) IBOutlet UIView *viewBottom;
@property(nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property(nonatomic, retain) IBOutlet UIView *viewEffects;
@property(nonatomic, retain) IBOutlet UIView *innerGlow;

@end
