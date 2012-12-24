//
//  DDDoubleDateBubble.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 12/24/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDateBubble.h"
#import "DDDoubleDateBubbleViewController.h"
#import "DDUser.h"
#import "DDPlacemark.h"
#import <QuartzCore/QuartzCore.h>

@implementation DDDoubleDateBubble

@synthesize height;
@synthesize user;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //load view controller
        viewController_ = [[DDDoubleDateBubbleViewController alloc] init];
        initialHeight_ = viewController_.view.frame.size.height;
        viewController_.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        viewController_.view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        viewController_.view.layer.cornerRadius = 5;
        [self addSubview:viewController_.view];
    }
    return self;
}

- (CGFloat)height
{
    return 0;
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
    
    //apply gender
    viewController_.imageViewGender.image = [UIImage imageNamed:[self.user.gender isEqualToString:DDUserGenderFemale]?@"dd-user-gender-indicator-female.png":@"dd-user-gender-indicator-male.png"];
    CGPoint centerGender = viewController_.imageViewGender.center;
    viewController_.imageViewGender.frame = CGRectMake(0, 0, viewController_.imageViewGender.image.size.width, viewController_.imageViewGender.image.size.height);
    viewController_.imageViewGender.center = CGPointMake(viewController_.labelTitle.frame.origin.x+viewController_.labelTitle.frame.size.width+genderOffset, centerGender.y);
}

- (void)dealloc
{
    [user release];
    [viewController_ release];
    [super dealloc];
}

@end
