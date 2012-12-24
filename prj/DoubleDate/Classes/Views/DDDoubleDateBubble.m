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
}

- (void)dealloc
{
    [user release];
    [viewController_ release];
    [super dealloc];
}

@end
