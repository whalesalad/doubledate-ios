//
//  DDUsersView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 12/24/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDUsersView.h"
#import "DDShortUser.h"
#import "DDUser.h"
#import "DDImageView.h"
#import "DDImage.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

#define kReloadDelay 3
#define kAnimationInterval 1

@interface DDUsersView ()

@property(nonatomic, retain) UIImageView *currentView;

@end

@implementation DDUsersView

@synthesize currentView;
@synthesize users;

- (UIImageView*)addNewImageView
{
    DDStyledImageView *ret = [[[DDStyledImageView alloc] initWithFrame:self.bounds] autorelease];
    ret.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:ret];
    return ret;
}

- (id)initWithPlaceholderImage:(UIImage *)placeholder
{
    if ((self = [super initWithFrame:CGRectZero]))
    {
        self.currentView = [self addNewImageView];
        self.currentView.image = placeholder;
    }
    return self;
}

- (NSURL*)randomUrl
{
    NSObject *randomUser = nil;
    if ([self.users count] > 1)
        randomUser = [self.users objectAtIndex:rand()%[self.users count]];
    else
        randomUser = [self.users lastObject];
    if ([randomUser isKindOfClass:[DDUser class]])
        return [NSURL URLWithString:[[(DDUser*)randomUser photo] thumbUrl]];
    else if ([randomUser isKindOfClass:[DDShortUser class]])
        return [NSURL URLWithString:[[(DDShortUser*)randomUser photo] thumbUrl]];
    return nil;
}

- (void)start
{
    //get random url
    NSURL *randomUrl = [self randomUrl];
    
    //check for no value
    if (!randomUrl)
        return;
    
    //add new subview
    UIImageView *updatedView = [self addNewImageView];
        
    //reload from url
    [updatedView setImageWithURL:randomUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
        //check for transition
        if (!self.currentView)
        {
            //update view
            self.currentView = updatedView;
        }
        else
        {
            //save old view
            UIView *oldView = self.currentView;
            
            //animate transition
            if (self.currentView.image)
            {
                [UIView transitionFromView:self.currentView toView:updatedView duration:kAnimationInterval options:(UIViewAnimationOptionTransitionFlipFromRight|UIViewAnimationOptionCurveEaseInOut) completion:^(BOOL finished) {
                    [oldView removeFromSuperview];
                }];
            }
            
            //save new view
            self.currentView = updatedView;
        }
        
        //repeat after delay
        if (self.superview)
            [self performSelector:@selector(start) withObject:nil afterDelay:kReloadDelay];
    }];
}

- (void)setUsers:(NSArray *)v
{
    //check for value
    if (users != v)
    {
        //save if users were before
        BOOL usersWereBefore = [users count] > 0;
        
        //update value
        [users release];
        users = [v retain];
        
        //start if no users before
        if (!usersWereBefore)
            [self start];
    }
}

- (void)dealloc
{
    [currentView release];
    [users release];
    [super dealloc];
}

@end
