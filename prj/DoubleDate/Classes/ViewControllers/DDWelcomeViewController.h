//
//  DDWelcomeViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@class DDAPIController;
@class DDUser;

@class KenBurnsView;

@interface DDWelcomeViewController : DDViewController
{
    CGFloat bottomViewVisibleHeight_;
    CGPoint initialLogoPosition_;
}

@property(nonatomic, assign) BOOL privacyShown;

@property(nonatomic, retain) IBOutlet UIView *bottomView;
@property(nonatomic, retain) IBOutlet UITextView *privacyTextView;
@property(nonatomic, retain) IBOutlet UIImageView *logoImageView;
@property(nonatomic, retain) IBOutlet UIView *fadeView;
@property(nonatomic, retain) IBOutlet UIButton *whyFacebookButton;
@property(nonatomic, retain) IBOutlet UIView *animateView;

- (IBAction)whyFacebookOutTouched:(id)sender;
- (IBAction)whyFacebookTouched:(id)sender;
- (IBAction)facebookTouched:(id)sender;
- (IBAction)emailTouched:(id)sender;

- (void)startWithUser:(DDUser*)user;

@end
