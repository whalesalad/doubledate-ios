//
//  DDDoubleDateBubbleViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 12/24/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDPhotoView;

@interface DDDoubleDateBubbleViewController : UIViewController

@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
@property(nonatomic, retain) IBOutlet UILabel *labelLocation;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewGender;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewGradient;
@property(nonatomic, retain) IBOutlet DDPhotoView *photoView;
@property(nonatomic, retain) IBOutlet UITextView *textView;
@property(nonatomic, retain) IBOutlet UIView *viewInterests;

@end
