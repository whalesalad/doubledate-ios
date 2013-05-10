//
//  DDUserView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 12/24/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDShortUser;
@class DDUser;

@class DDImageView;

@interface DDUserView : UIView
{
}

@property(nonatomic, retain) DDShortUser *shortUser;
@property(nonatomic, retain) DDUser *user;
@property(nonatomic, retain) NSString *customTitle;

@property(nonatomic, retain) IBOutlet DDImageView *imageViewPhoto;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewGender;
@property(nonatomic, retain) IBOutlet UILabel *labelTitle;

@end
