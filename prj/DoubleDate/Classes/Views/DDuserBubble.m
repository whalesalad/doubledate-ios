//
//  DDUserBubble.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 12/24/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDUserBubble.h"
#import "DDUserBubbleViewController.h"
#import "DDUser.h"
#import "DDPlacemark.h"
#import "DDPhotoView.h"
#import "DDInterest.h"
#import "DDTools.h"
#import "UIView+Interests.h"
#import "DDImageView.h"
#import "DDImage.h"
#import <QuartzCore/QuartzCore.h>

@implementation DDUserBubble

@synthesize height;
@synthesize user;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //load view controller
        viewController_ = [[DDUserBubbleViewController alloc] init];
        initialHeight_ = viewController_.view.frame.size.height;
        viewController_.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        viewController_.view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:viewController_.view];
    }
    return self;
}

- (CGFloat)height
{
    return viewController_.viewInterests.frame.origin.y + viewController_.viewInterests.frame.size.height + viewController_.view.layer.cornerRadius;
}

- (void)setUser:(DDUser *)v
{
    //check the same value
    if (v != user)
    {
        //update value
        [user release];
        user = [v retain];
        
        //update UI
        [self updateUI];
    }
}

- (void)reinitInterests
{
    CGRect oldInterestsFrame = viewController_.viewInterests.frame;
    CGFloat newInterestsHeight = [viewController_.viewInterests applyInterests:self.user.interests
                                                                   bubbleImage:[UIImage imageNamed:@"dd-user-bubble-interest-item.png"]
                                                            matchedBubbleImage:[UIImage imageNamed:@"dd-user-bubble-interest-item-matched.png"]
                                                         custmomizationHandler:^(UILabel *bubbleLabel)
                                  {
                                      bubbleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                                      DD_F_INTEREST_TEXT(bubbleLabel);
                                      bubbleLabel.backgroundColor = [UIColor clearColor];
                                  }];
    viewController_.viewInterests.frame = CGRectMake(oldInterestsFrame.origin.x, oldInterestsFrame.origin.y, oldInterestsFrame.size.width, newInterestsHeight);
}

- (void)updateUI
{
    //gender offset
    CGFloat genderOffset = viewController_.imageViewGender.center.x-viewController_.labelTitle.frame.origin.x-viewController_.labelTitle.frame.size.width;
    
    //fill data
    viewController_.labelTitle.text = [NSString stringWithFormat:@"%@, %d", [self.user firstName], [[self.user age] intValue]];
    viewController_.labelTitle.text = [viewController_.labelTitle.text uppercaseString];
    CGSize newSize = [viewController_.labelTitle sizeThatFits:viewController_.labelTitle.frame.size];
    [viewController_.labelTitle setFrame:CGRectMake(viewController_.labelTitle.frame.origin.x, viewController_.labelTitle.frame.origin.y, newSize.width, viewController_.labelTitle.frame.size.height)];
    viewController_.labelLocation.text = self.user.location.name;
    viewController_.textView.text = self.user.bio;
    viewController_.labelKarma.text = [NSString stringWithFormat:@"%d", [self.user.totalKarma intValue]];
    
    //apply gender
    viewController_.imageViewGender.image = [UIImage imageNamed:[self.user.gender isEqualToString:DDUserGenderFemale]?@"dd-user-gender-indicator-bubble-female.png":@"dd-user-gender-indicator-bubble-male.png"];
    CGPoint centerGender = viewController_.imageViewGender.center;
    viewController_.imageViewGender.frame = CGRectMake(0, 0, viewController_.imageViewGender.image.size.width, viewController_.imageViewGender.image.size.height);
    viewController_.imageViewGender.center = CGPointMake(viewController_.labelTitle.frame.origin.x+viewController_.labelTitle.frame.size.width+genderOffset, centerGender.y);
    
    //apply photo
    [viewController_.photoView reloadFromUrl:[NSURL URLWithString:self.user.photo.mediumUrl]];
    
    //apply bio
    CGSize textViewSizeBefore = viewController_.textView.frame.size;
    viewController_.textView.text = self.user.bio;
    viewController_.textView.frame = CGRectMake(viewController_.textView.frame.origin.x, viewController_.textView.frame.origin.y, viewController_.textView.contentSize.width, MAX(viewController_.textView.contentSize.height, 60));
    CGFloat dtvh = textViewSizeBefore.height - viewController_.textView.frame.size.height;
    
    //move view
    viewController_.viewInterests.center = CGPointMake(viewController_.viewInterests.center.x, viewController_.viewInterests.center.y-dtvh);
    viewController_.labelIceBreakers.center = CGPointMake(viewController_.labelIceBreakers.center.x, viewController_.labelIceBreakers.center.y-dtvh);
    
    //reinit interests
    [self reinitInterests];
    viewController_.viewBottom.frame = CGRectMake(viewController_.viewBottom.frame.origin.x, viewController_.viewInterests.frame.origin.y + viewController_.viewInterests.frame.size.height, viewController_.viewBottom.frame.size.width, viewController_.viewBottom.frame.size.height);
    
    //make rounded corners
    viewController_.viewMain.layer.masksToBounds = YES;
    viewController_.viewMain.layer.cornerRadius = 5;
}

- (void)dealloc
{
    [user release];
    [viewController_ release];
    [super dealloc];
}

@end
