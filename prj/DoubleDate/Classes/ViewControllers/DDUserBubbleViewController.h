//
//  DDUserBubbleViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 11/20/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@interface DDUserBubbleViewController : UIViewController
{
}

@property(nonatomic, retain) DDUser *user;

@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewGender;
@property(nonatomic, retain) IBOutlet UILabel *labelLocation;
@property(nonatomic, retain) IBOutlet UITextView *textViewInfo;

@end
