//
//  DDTableViewController+Refresh.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewController+Refresh.h"

@implementation DDTableViewController (Refresh)

- (UIRefreshControl*)sharedRefreshControl
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6)
    {
        if ([self isKindOfClass:[UITableViewController class]])
        {
            if (!self.refreshControl)
            {
                self.refreshControl = [[[UIRefreshControl alloc] init] autorelease];
                [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
            }
            return self.refreshControl;
        }
    }
    return nil;
}

- (void)refreshControlValueChanged:(UIRefreshControl*)sender
{
    [self startRefreshWithText:NSLocalizedString(@"Loading...", nil)];
}

- (void)startRefreshWithText:(NSString*)text
{
    //check if refresh control exist
    if ([self sharedRefreshControl])
        [[self sharedRefreshControl] beginRefreshing];
    //    else
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
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateStyle:kCFDateFormatterShortStyle];
        [dateFormatter setTimeStyle:kCFDateFormatterShortStyle];
        [self sharedRefreshControl].attributedTitle = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Last updated: %@", nil), [dateFormatter stringFromDate:[NSDate date]]]] autorelease];
        [[self sharedRefreshControl] endRefreshing];
    }
    //    else
        [self hideHud:YES];
}

@end
