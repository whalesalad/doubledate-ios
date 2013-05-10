//
//  DDUserBubble.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 12/24/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
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
    if ([[[self user] bio] length])
        return CGRectGetMaxY(viewController_.textView.frame) + viewController_.view.layer.cornerRadius + 4;
    return CGRectGetMaxY(viewController_.labelTitle.frame) + viewController_.view.layer.cornerRadius + 4;
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

- (void)updateUI
{
    //update page control
    viewController_.pageControl.numberOfPages = [self.users count];
    viewController_.pageControl.hidden = [self.users count] <= 1;
        
    //fill data
    viewController_.labelTitle.text = [NSString stringWithFormat:@"%@, %d", [self.user firstName], [[self.user age] intValue]];
    CGSize newSize = [viewController_.labelTitle sizeThatFits:viewController_.labelTitle.frame.size];
    [viewController_.labelTitle setFrame:CGRectMake(viewController_.labelTitle.frame.origin.x, viewController_.labelTitle.frame.origin.y, newSize.width, viewController_.labelTitle.frame.size.height)];
    viewController_.labelLocation.text = self.user.location.name;
    viewController_.textView.text = self.user.bio;
    
    //apply gender
    viewController_.imageViewGender.image = [UIImage imageNamed:[self.user.gender isEqualToString:DDUserGenderFemale]?@"icon-gender-female.png":@"icon-gender-male.png"];
    
    //apply photo
    [viewController_.photoView reloadFromUrl:[NSURL URLWithString:self.user.photo.squareUrl]];
    
    //apply bio
    viewController_.textView.text = self.user.bio;
    viewController_.textView.frame = CGRectMake(viewController_.textView.frame.origin.x, viewController_.textView.frame.origin.y, viewController_.textView.contentSize.width, MAX(viewController_.textView.contentSize.height + 10, 60));
    
    //update bottom position
    viewController_.viewBottom.frame = CGRectMake(viewController_.viewBottom.frame.origin.x, viewController_.textView.frame.origin.y + viewController_.textView.frame.size.height, viewController_.viewBottom.frame.size.width, viewController_.viewBottom.frame.size.height);
    
    //show/hide bio
    viewController_.textView.hidden = [[[self user] bio] length] == 0;
}

- (void)dealloc
{
    [users release];
    [viewController_ release];
    [super dealloc];
}

@end
