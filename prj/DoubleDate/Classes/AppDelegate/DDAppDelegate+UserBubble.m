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
#import <QuartzCore/QuartzCore.h>

@implementation DDAppDelegate (UserBubble)

- (void)presentUserBubbleForUser:(DDUser*)user fromUsers:(NSArray*)users
{
    //remove old
    [self.userPopover removeFromSuperview];
    
    //add view
    self.userPopover = [[[UIImageView alloc] initWithImage:[DDTools blurFromImage:[DDTools imageFromView:self.window]]] autorelease];
    self.userPopover.userInteractionEnabled = YES;
    self.userPopover.alpha = 0;
    
    // Add darkness to blurred image.
    CALayer *dim = [CALayer layer];
    dim.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7f].CGColor;
    dim.frame = self.userPopover.bounds;
    [self.userPopover.layer addSublayer:dim];
    
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self.userPopover];
    
    //add scroll view
    UIScrollView *sv = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.userPopover.bounds.size.width, self.userPopover.bounds.size.height)] autorelease];
    sv.contentSize = CGSizeMake(self.userPopover.bounds.size.width*[users count], self.userPopover.bounds.size.height);
    sv.pagingEnabled = [users count]>1;
    sv.delegate = self;
    sv.showsHorizontalScrollIndicator = NO;
    sv.tag = 100;
    [self.userPopover addSubview:sv];
    
    //add tap recognizer
    UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissUserPopover)] autorelease];
    [sv addGestureRecognizer:tapRecognizer];
    
    //add gesture recognizer for close
    UISwipeGestureRecognizer *swipeRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissUserPopover)] autorelease];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [sv addGestureRecognizer:swipeRecognizer];
    
    //add page control
    UIPageControl *pageControl = [[[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 80, 36)] autorelease];
    // XXX Controlling page position
    pageControl.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height-40);
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.numberOfPages = [users count];
    [pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
    [self.userPopover addSubview:pageControl];
    
    //bubbles storage
    NSMutableArray *bubbles = [NSMutableArray array];
    CGFloat maxBubbleHeight = FLT_MIN;
    
    //add bubbles
    CGRect bubbleRect = CGRectMake(25, 40, 250, 0);
    for (int i = 0; i < [users count]; i++)
    {
        //create bubble
        DDUserBubble *bubble = [[[DDUserBubble alloc] initWithFrame:bubbleRect] autorelease];
        bubble.users = [NSArray arrayWithObject:[users objectAtIndex:i]];
        bubble.frame = CGRectMake(bubbleRect.origin.x, bubbleRect.origin.y, bubbleRect.size.width, bubble.height);
        bubble.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2+[UIScreen mainScreen].bounds.size.width*i, [UIScreen mainScreen].bounds.size.height/2);
        [sv addSubview:bubble];
        [bubbles addObject:bubble];
        
        //save maximal height
        maxBubbleHeight = MAX(maxBubbleHeight, bubble.height);
    }
    
    //move bubbles to top
    for (DDUserBubble *bubble in bubbles)
        bubble.center = CGPointMake(bubble.center.x, bubble.center.y - (maxBubbleHeight - bubble.height) / 2);
    
    //set needed current page
    pageControl.currentPage = [users indexOfObject:user];
    
    //check for needed page
    sv.contentOffset = CGPointMake([UIScreen mainScreen].bounds.size.width * [users indexOfObject:user], 0);
    
    //animate appearing
    [UIView animateWithDuration:0.3f animations:^{
        self.userPopover.alpha = 1;
    }];
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
    
    //set content offset
    CGFloat pageWidth = sv.contentSize.width /sender.numberOfPages;
    CGFloat x = sender.currentPage * pageWidth;
    [sv scrollRectToVisible:CGRectMake(x, 0, pageWidth, sv.frame.size.height) animated:YES];
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

@end
