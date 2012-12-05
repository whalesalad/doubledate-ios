//
//  DDSelectWingView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDSelectWingView.h"
#import "DDAPIController.h"
#import "DDShortUser.h"

@interface DDSelectWingView (API) <DDAPIControllerDelegate>

- (void)updateUI;

@end

@implementation DDSelectWingView

@synthesize delegate;

- (void)initSelf
{
    //add api controller
    apiController_ = [[DDAPIController alloc] init];
    apiController_.delegate = self;
    
    //add loading
    loading_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loading_.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    loading_.hidesWhenStopped = YES;
    loading_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:loading_];
    
    //add label
    label_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    label_.backgroundColor = [UIColor clearColor];
    label_.textAlignment = NSTextAlignmentCenter;
    label_.textColor = [UIColor whiteColor];
    [self addSubview:label_];
    
    //add gesture recognizers
    UISwipeGestureRecognizer *gestureRecognizerRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)] autorelease];
    [gestureRecognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self addGestureRecognizer:gestureRecognizerRight];
    UISwipeGestureRecognizer *gestureRecognizerLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)] autorelease];
    [gestureRecognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:gestureRecognizerLeft];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self initSelf];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initSelf];
    }
    return self;
}

- (void)dealloc
{
    apiController_.delegate = nil;
    [apiController_ release];
    [loading_ release];
    [label_ release];
    [wings_ release];
    [super dealloc];
}

- (void)swipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    //check if wings are exist
    if (![wings_ count])
        return;
    
    //check state
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        //update index
        if ([gestureRecognizer direction] == UISwipeGestureRecognizerDirectionRight)
            curWingIndex_++;
        else if ([gestureRecognizer direction] == UISwipeGestureRecognizerDirectionLeft)
            curWingIndex_--;
        
        //check index
        if (curWingIndex_ >= (int)[wings_ count])
            curWingIndex_ = 0;
        if (curWingIndex_ < 0)
            curWingIndex_ = (int)[wings_ count] - 1;
        if (curWingIndex_ < 0)
            curWingIndex_ = 0;
        
        //update UI
        [self applyChange];
    }
}

- (void)applyChange
{
    //change label
    [label_ setText:self.wing.firstName];
    
    //inform delegate
    [self.delegate selectWingViewDidSelectWing:self];
}

- (void)start
{
    //show loading
    [loading_ startAnimating];
    
    //make a request
    [apiController_ getFriends];
}

- (DDShortUser*)wing
{
    if (curWingIndex_ >= 0 && curWingIndex_ < [wings_ count])
        return [wings_ objectAtIndex:curWingIndex_];
    return nil;
}

#pragma mark -
#pragma mark DDAPIControllerDelegate

- (void)getFriendsSucceed:(NSArray*)friends
{
    //stop loading
    [loading_ stopAnimating];
    
    //update wings
    [wings_ release];
    wings_ = [friends retain];
    
    //apply change
    [self applyChange];
}

- (void)getFriendsDidFailedWithError:(NSError*)error
{
    //stop loading
    [loading_ stopAnimating];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
