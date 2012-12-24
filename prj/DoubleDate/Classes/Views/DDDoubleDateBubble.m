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
#import "DDPhotoView.h"
#import "DDInterest.h"
#import "DDTools.h"
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
    //remove all interests
    while ([[viewController_.viewInterests subviews] count])
        [[[viewController_.viewInterests subviews] lastObject] removeFromSuperview];
    
    //add interesets
    CGFloat outHorPadding = 4;
    CGFloat outVerPadding = 6;
    CGFloat curX = outHorPadding;
    CGFloat curY = outVerPadding;
    CGFloat totalInterestsHeight = 0;
    CGRect oldInterestsFrame = viewController_.viewInterests.frame;
    for (DDInterest *interest in self.user.interests)
    {
        //edge padding inside the bubble
        CGFloat inEdgePadding = 6;
        
        //create label
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        label.font = [UIFont systemFontOfSize:12];
        label.text = [interest.name uppercaseString];
        label.backgroundColor = [UIColor clearColor];
        [label sizeToFit];
        
        //create background image
        UIImage *labelBackgroundImage = [UIImage imageNamed:@"dd-user-bubble-interest-item.png"];
        UIImageView *labelBackground = [[[UIImageView alloc] initWithFrame:CGRectMake(curX, curY, label.frame.size.width+2*inEdgePadding, labelBackgroundImage.size.height)] autorelease];
        labelBackground.image = [DDTools resizableImageFromImage:labelBackgroundImage];
        
        //add label
        label.center = CGPointMake(labelBackground.frame.size.width/2, labelBackground.frame.size.height/2-1);
        [labelBackground addSubview:label];
        
        DD_F_BUBBLE_INTEREST_TEXT(label);
        
        //add image view
        [viewController_.viewInterests addSubview:labelBackground];
        
        //move horizontally
        curX = labelBackground.frame.origin.x + labelBackground.frame.size.width + outHorPadding;
        
        //check if out of the bounds
        if (curX > viewController_.viewInterests.frame.size.width)
        {
            //update current frame
            curY = labelBackground.frame.origin.y + labelBackground.frame.size.height + outVerPadding;
            curX = outHorPadding;
            labelBackground.frame = CGRectMake(curX, curY, labelBackground.frame.size.width, labelBackground.frame.size.height);
            
            //set up new frame
            curX = labelBackground.frame.origin.x + labelBackground.frame.size.width + outHorPadding;
        }
        
        //save total height
        totalInterestsHeight = labelBackground.frame.origin.y + labelBackground.frame.size.height + outVerPadding;
    }
    CGFloat newInterestsHeight = totalInterestsHeight;
    
    //maximum 6 rows + 7 paddings
    newInterestsHeight = MIN(MAX(newInterestsHeight, 0), 27*6+outVerPadding*7);
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
    
    //apply gender
    viewController_.imageViewGender.image = [UIImage imageNamed:[self.user.gender isEqualToString:DDUserGenderFemale]?@"dd-user-gender-indicator-female.png":@"dd-user-gender-indicator-male.png"];
    CGPoint centerGender = viewController_.imageViewGender.center;
    viewController_.imageViewGender.frame = CGRectMake(0, 0, viewController_.imageViewGender.image.size.width, viewController_.imageViewGender.image.size.height);
    viewController_.imageViewGender.center = CGPointMake(viewController_.labelTitle.frame.origin.x+viewController_.labelTitle.frame.size.width+genderOffset, centerGender.y);
    
    //apply photo
    [viewController_.photoView applyImage:self.user.photo];
    
    //apply bio
    CGSize textViewSizeBefore = viewController_.textView.frame.size;
    viewController_.textView.text = self.user.bio;
    viewController_.textView.frame = CGRectMake(viewController_.textView.frame.origin.x, viewController_.textView.frame.origin.y, viewController_.textView.contentSize.width, MAX(viewController_.textView.contentSize.height, 60));
    CGFloat dtvh = textViewSizeBefore.height - viewController_.textView.frame.size.height;
    
    //move interests view
    viewController_.viewInterests.center = CGPointMake(viewController_.viewInterests.center.x, viewController_.viewInterests.center.y-dtvh);
    
    //reinit interests
    [self reinitInterests];
    
    //make rounded corners
    viewController_.view.layer.masksToBounds = YES;
    viewController_.view.layer.cornerRadius = 5;    
}

- (void)dealloc
{
    [user release];
    [viewController_ release];
    [super dealloc];
}

@end
