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
@synthesize users;

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
        
        //add gesture recognizer
        UISwipeGestureRecognizer *swipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)] autorelease];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeLeft];
        UISwipeGestureRecognizer *swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)] autorelease];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeRight];
    }
    return self;
}

- (void)swipe:(UISwipeGestureRecognizer*)sender
{
    //swipe only if more than 1 user
    if ([self.users count] <= 1)
        return;
    
    //update frame
    CGPoint center = self.center;
    
    //change direction
    if ([sender direction] == UISwipeGestureRecognizerDirectionLeft)
    {
        if (self.currentUserIndex == [self.users count] - 1)
            self.currentUserIndex = 0;
        else
            self.currentUserIndex++;
    }
    else if ([sender direction] == UISwipeGestureRecognizerDirectionRight)
    {
        if (self.currentUserIndex == 0)
            self.currentUserIndex = [self.users count] - 1;
        else
            self.currentUserIndex--;
    }
    
    //update UI
    [self updateUI];
    
    //update frame
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.height);
    
    //update center
    self.center = center;
}

- (CGFloat)height
{
    return viewController_.viewInterests.frame.origin.y + viewController_.viewInterests.frame.size.height + viewController_.view.layer.cornerRadius + 4;
}

- (void)setUsers:(NSArray *)v
{
    //check the same value
    if (v != users)
    {
        //update value
        [users release];
        users = [v retain];
        
        //update UI
        [self updateUI];
    }
}

- (void)setCurrentUserIndex:(NSInteger)currentUserIndex
{
    viewController_.pageControl.currentPage = currentUserIndex;
}

- (NSInteger)currentUserIndex
{
    return viewController_.pageControl.currentPage;
}

- (DDUser*)user
{
    if (viewController_.pageControl.currentPage < [self.users count])
        return [self.users objectAtIndex:viewController_.pageControl.currentPage];
    return nil;
}

- (void)reinitInterests
{
    while ([[viewController_.viewInterests subviews] count])
        [[[viewController_.viewInterests subviews] lastObject] removeFromSuperview];
    CGRect oldInterestsFrame = viewController_.viewInterests.frame;
    CGFloat newInterestsHeight = [viewController_.viewInterests applyInterestsForUser:self.user
                                  
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
    //update page control
    viewController_.pageControl.numberOfPages = [self.users count];
    viewController_.pageControl.hidden = [self.users count] <= 1;
    
    //gender offset
    CGFloat genderOffset = viewController_.imageViewGender.center.x-viewController_.labelTitle.frame.origin.x-viewController_.labelTitle.frame.size.width;
    
    //fill data
    viewController_.labelTitle.text = [NSString stringWithFormat:@"%@, %d", [self.user firstName], [[self.user age] intValue]];
    CGSize newSize = [viewController_.labelTitle sizeThatFits:viewController_.labelTitle.frame.size];
    [viewController_.labelTitle setFrame:CGRectMake(viewController_.labelTitle.frame.origin.x, viewController_.labelTitle.frame.origin.y, newSize.width, viewController_.labelTitle.frame.size.height)];
    viewController_.labelLocation.text = self.user.location.name;
    viewController_.textView.text = self.user.bio;
    
    //apply gender
    viewController_.imageViewGender.image = [UIImage imageNamed:[self.user.gender isEqualToString:DDUserGenderFemale]?@"icon-gender-female.png":@"icon-gender-male.png"];
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
    
    [viewController_.viewEffects setFrame:CGRectMake(-1, -1, self.frame.size.width+2, self.height+2)];
    
    viewController_.viewEffects.layer.shadowPath = [[UIBezierPath bezierPathWithRect:viewController_.viewEffects.bounds] CGPath];
    
    viewController_.viewEffects.layer.masksToBounds = NO;
    viewController_.viewEffects.layer.cornerRadius = 6;
}

- (void)dealloc
{
    [users release];
    [viewController_ release];
    [super dealloc];
}

@end
