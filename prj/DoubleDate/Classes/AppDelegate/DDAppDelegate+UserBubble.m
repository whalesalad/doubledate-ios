//
//  DDAppDelegate+UserBubble.m
//  DoubleDate
//
//  Created by Gennadii Ivanov
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAppDelegate+UserBubble.h"
#import "DDTools.h"
#import "DDUser.h"
#import "DDUserBubble.h"
#import "UIImage+DD.h"
#import "DDStatisticsController.h"
#import "DDTouchRedirectView.h"
#import <QuartzCore/QuartzCore.h>

#define kBubbleWidth 270

@implementation DDAppDelegate (UserBubble)

- (void)presentUserBubbleForUser:(DDUser*)user fromUsers:(NSArray*)users
{    
    // Remove old popovers
    [self.userPopover removeFromSuperview];
    
    // Create blurred background image
    UIImage *blurImage = [[DDTools screenshot] blurImage];
    self.userPopover = [[[UIImageView alloc] initWithFrame:self.window.bounds] autorelease];
    ((UIImageView*)self.userPopover).image = blurImage;
    
    self.userPopover.userInteractionEnabled = YES;
    self.userPopover.alpha = 0;
    [self.window addSubview:self.userPopover];
    
    // Add dim overlay
    UIView *dim = [[[UIView alloc] initWithFrame:self.userPopover.bounds] autorelease];
    dim.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8f];
    [self.userPopover addSubview:dim];
    
    // Create Scroll View
    UIScrollView *sv = [[[UIScrollView alloc] initWithFrame:CGRectMake(25, 40, kBubbleWidth, self.userPopover.bounds.size.height - 40)] autorelease];
    sv.clipsToBounds = NO;
    sv.pagingEnabled = [users count] > 1;
    sv.delegate = self;
    sv.showsHorizontalScrollIndicator = NO;
    sv.tag = 100;
    
    [self.userPopover addSubview:sv];
    
    // Tap to close
    UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissUserPopover)] autorelease];
    [sv addGestureRecognizer:tapRecognizer];
    
    // Swipe down to close
    UISwipeGestureRecognizer *swipeRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissUserPopover)] autorelease];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [sv addGestureRecognizer:swipeRecognizer];
    
    // Page control
    UIPageControl *pageControl = [[[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 80, 36)] autorelease];
    
    pageControl.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,
                                     [UIScreen mainScreen].bounds.size.height-20);
    
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.numberOfPages = [users count];

    [pageControl addTarget:self
                    action:@selector(pageChanged:)
          forControlEvents:UIControlEventValueChanged];
    
    pageControl.hidden = [users count] == 1;
    
    [self.userPopover addSubview:pageControl];
    
    //bubbles storage
    NSMutableArray *bubbles = [NSMutableArray array];
    CGFloat maxBubbleHeight = FLT_MIN;
    
    // add bubbles
    CGRect bubbleRect = CGRectMake(0, 20, 250, 0);
    
    for (int i = 0; i < [users count]; i++)
    {
        //create bubble
        DDUserBubble *bubble = [[[DDUserBubble alloc] initWithFrame:bubbleRect] autorelease];
        
        bubble.users = [NSArray arrayWithObject:[users objectAtIndex:i]];
        bubble.frame = CGRectMake(i*kBubbleWidth, 0, kBubbleWidth, bubble.height);
        bubble.tag = i;
        
        [sv addSubview:bubble];
        [bubbles addObject:bubble];
        
        //save maximal height
        maxBubbleHeight = MAX(maxBubbleHeight, bubble.height);
    }
    
    // Set current page
    pageControl.currentPage = [users indexOfObject:user];
    
    // Set the current page of the scrollview
    sv.contentOffset = CGPointMake(kBubbleWidth * [users indexOfObject:user], 0);
    
    // Set the scroll view content size
    sv.contentSize = CGSizeMake(kBubbleWidth * [users count], sv.frame.size.height);
    
    //add touch redirect view
    DDTouchRedirectView *redirectView = [[[DDTouchRedirectView alloc] initWithFrame:self.userPopover.bounds] autorelease];
    redirectView.backgroundColor = [UIColor clearColor];
    redirectView.redirectView = sv;
    [self.userPopover addSubview:redirectView];
    
    //animate appearing
    [UIView animateWithDuration:0.3f animations:^{
        self.userPopover.alpha = 1;
    }];
    
    //update opacity of bubbles
    [self scrollViewDidScroll:sv];
    
    // Track Event
    [DDStatisticsController trackEvent:DDStatisticsUserOpenedBubble
                        withProperties:[NSDictionary dictionaryWithObjectsAndKeys:user.userId, @"user_id", nil]];

}

- (void)dismissUserPopover
{
    if (self.userPopover)
    {
        UIView *scrollView = [self.userPopover viewWithTag:100];
        CGPoint newCenter = scrollView.center;
        newCenter.y += 100;
        [UIView animateWithDuration:0.2f animations:^{
            scrollView.center = newCenter;
            self.userPopover.alpha = 0;
        } completion:^(BOOL finished) {
            [self.userPopover removeFromSuperview];
            self.userPopover = nil;
        }];
    }
}

- (void)pageChanged:(UIPageControl*)sender
{
    //get scroll view
    UIScrollView *sv = nil;
    for (UIScrollView *v in [sender.superview subviews])
    {
        if ([v isKindOfClass:[UIScrollView class]])
            sv = v;
    }
    
    CGFloat x = kBubbleWidth + sender.numberOfPages;
    
    [sv scrollRectToVisible:CGRectMake(x, 0, kBubbleWidth, sv.frame.size.height) animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender
{
    //get page view
    UIPageControl *pc = nil;
    for (UIPageControl *v in [sender.superview subviews])
    {
        if ([v isKindOfClass:[UIPageControl class]])
            pc = v;
    }
    
    //set current page
    pc.currentPage = lround(sender.contentOffset.x / (sender.contentSize.width / pc.numberOfPages));
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    //get page view
    UIPageControl *pc = nil;
    for (UIPageControl *v in [sender.superview subviews])
    {
        if ([v isKindOfClass:[UIPageControl class]])
            pc = v;
    }
    
    //save current page number
    CGFloat currentPage = sender.contentOffset.x / (sender.contentSize.width / pc.numberOfPages);
    
    //check each bubble
    for (DDUserBubble *bubble in [sender subviews])
    {
        if ([bubble isKindOfClass:[DDUserBubble class]])
        {
            CGFloat diff = fabs(currentPage - bubble.tag);
            if (diff > 1)
                diff = 1;
            bubble.alpha = 1.0f - 0.7f * diff;
        }
    }
}

@end
