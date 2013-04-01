//
//  DDWelcomeViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
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

@property(nonatomic, retain) IBOutlet UILabel *labelGrabAFriend;
@property(nonatomic, retain) IBOutlet UIButton *buttonLoginWithFacebook;

- (IBAction)whyFacebookOutTouched:(id)sender;
- (IBAction)whyFacebookTouched:(id)sender;
- (IBAction)facebookTouched:(id)sender;
- (IBAction)emailTouched:(id)sender;

- (void)startWithUser:(DDUser*)user;

@end
