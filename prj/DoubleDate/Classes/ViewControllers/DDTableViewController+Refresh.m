//
//  DDTableViewController+Refresh.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewController+Refresh.h"

@implementation DDTableViewController (Refresh)

- (void)setupRefreshControl
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6)
    {
        if (!self.refreshControl)
        {
            self.refreshControl = [[[UIRefreshControl alloc] init] autorelease];
            self.refreshControl.tintColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
            [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        }
    }
}

- (void)unsetupRefreshControl
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6)
        self.refreshControl = nil;
}

- (UIRefreshControl*)sharedRefreshControl
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6)
        return self.refreshControl;
    return nil;
}

- (BOOL)isRefreshControlEnabled
{
    return [self sharedRefreshControl] != nil;
}

- (void)setIsRefreshControlEnabled:(BOOL)v
{
    if (v)
        [self setupRefreshControl];
    else
        [self unsetupRefreshControl];
}

- (void)refreshControlValueChanged:(UIRefreshControl*)sender
{
    if (sender == [self sharedRefreshControl])
        [self startRefreshWithText:NSLocalizedString(@"Loading...", nil)];
}

- (void)onChangedSearchTerm
{
    
}

- (void)startRefreshWithText:(NSString*)text
{
    //check if refresh control exist
    if ([self sharedRefreshControl])
    {
        //disable touch
        self.view.userInteractionEnabled = NO;
        
        //start refreshing
        [[self sharedRefreshControl] beginRefreshing];
    }
    else
        [self showHudWithText:text animated:YES];
    
    //refresh
    [self onRefresh];
}

- (void)onRefresh
{
    
}

- (void)finishRefresh
{
    //check if refresh control exist
    if ([self sharedRefreshControl])
    {
        //enable touch
        self.view.userInteractionEnabled = YES;
        
        //update label
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateStyle:kCFDateFormatterShortStyle];
        [dateFormatter setTimeStyle:kCFDateFormatterShortStyle];

        NSMutableAttributedString *updatedText = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Updated %@", nil), [dateFormatter stringFromDate:[NSDate date]]]] autorelease];
        [updatedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:0.3f alpha:1.0f] range:NSMakeRange(0,updatedText.length)];

        NSShadow *updatedTextShadow = [[NSShadow alloc] init];
        [updatedTextShadow setShadowBlurRadius:0.5f];
        [updatedTextShadow setShadowColor:[UIColor colorWithWhite:0 alpha:0.7f]];
        [updatedTextShadow setShadowOffset:CGSizeMake(0, 1)];
        
        [updatedText addAttribute:NSShadowAttributeName value:updatedTextShadow range:NSMakeRange(0,updatedText.length)];
        
        [self sharedRefreshControl].attributedTitle = updatedText;

        //stop refreshing
        [[self sharedRefreshControl] endRefreshing];
    }
    else
        [self hideHud:YES];
}

@end
