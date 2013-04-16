//
//  DDNavigationMenu.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 2/5/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDNavigationMenu.h"
#import "DDNavigationMenuTableViewCell.h"
#import "DDAppDelegate.h"
#import "DDAuthenticationController.h"
#import "DDUser.h"
#import "UIViewController+Extensions.h"
#import "DDAppDelegate+NavigationMenu.h"
#import "BCTabBarController.h"
#import "DDDoubleDatesViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DDNavigationMenu () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation DDNavigationMenu

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 7 * [DDNavigationMenuTableViewCell height])];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav-bg.png"]];
        self.separatorColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        self.delegate = self;
        self.dataSource = self;
        self.scrollEnabled = NO;
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2.0f);
        self.layer.shadowOpacity = 0.7f;
        self.layer.shadowRadius = 4.0f;
        self.clipsToBounds = NO;
        
    }
    return self;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DDNavigationMenuTableViewCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDAppDelegate *appDelegate = (DDAppDelegate*)[[UIApplication sharedApplication] delegate];
    BCTabBarController *tabBarController = nil;
    if ([appDelegate.viewController isKindOfClass:[UINavigationController class]])
    {
        NSArray *viewControllers = [(UINavigationController*)appDelegate.viewController viewControllers];
        for (BCTabBarController *c in viewControllers)
        {
            if ([c isKindOfClass:[BCTabBarController class]] && [viewControllers indexOfObject:c] == 1)
                tabBarController = c;
        }
        if ([appDelegate.viewController.presentedViewController isKindOfClass:[BCTabBarController class]])
            tabBarController = (BCTabBarController*)appDelegate.viewController.presentedViewController;
    }
    NSInteger realIndex = indexPath.row - 1;
    if (realIndex >= 0 && realIndex < [tabBarController.viewControllers count])
    {
        [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] dismissNavigationMenu];
        tabBarController.selectedIndex = realIndex;
    }
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //save class
    Class cellClass = [DDNavigationMenuTableViewCell class];
    
    //create cell
    DDNavigationMenuTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:[cellClass description]];
    if (!cell)
        cell = [[[UINib nibWithNibName:[cellClass description] bundle:nil] instantiateWithOwner:aTableView options:nil] objectAtIndex:0];
        
    //save center of the icon
    CGPoint iconCenter = cell.imageViewIcon.center;
    
    //save badge number
    NSInteger badgeNumber = 0;
        
    switch (indexPath.row) {
        case 0:
            cell.imageViewIcon.image = nil;
            cell.labelTitle.text = nil;
            break;
        case 1:
            cell.imageViewIcon.image = [UIImage imageNamed:@"nav-icon-notifications.png"];
            cell.labelTitle.text = NSLocalizedString(@"Notifications", @"Notifications primary navigation item");
            badgeNumber = [[DDAuthenticationController currentUser].unreadNotificationsCount intValue];
            break;
        case 2:
            cell.imageViewIcon.image = [UIImage imageNamed:@"nav-icon-profile.png"];
            cell.labelTitle.text = [[DDAuthenticationController currentUser] firstName];
            break;
        case 3:
            cell.imageViewIcon.image = [UIImage imageNamed:@"nav-icon-wings.png"];
            cell.labelTitle.text = NSLocalizedString(@"Wings", @"Wings primary navigation item");
            badgeNumber = [[DDAuthenticationController currentUser].pendingWingsCount intValue];
            break;
        case 4:
            cell.imageViewIcon.image = [UIImage imageNamed:@"nav-icon-explore.png"];
            cell.labelTitle.text = [NSString stringWithFormat:NSLocalizedString(@"Explore %@", nil), [DDDoubleDatesViewController filterCityName]];
            break;
        case 5:
            cell.imageViewIcon.image = [UIImage imageNamed:@"nav-icon-doubledates.png"];
            cell.labelTitle.text = NSLocalizedString(@"DoubleDates", nil);
            break;
        case 6:
            cell.imageViewIcon.image = [UIImage imageNamed:@"nav-icon-messages.png"];
            cell.labelTitle.text = NSLocalizedString(@"Messages", @"Messages primary navigation item");
            badgeNumber = [[DDAuthenticationController currentUser].unreadMessagesCount intValue];
            break;
        default:
            break;
    }
    
    //hide badge image view if no text
    cell.badgeNumber = badgeNumber;
    
    //restore center of the icon
    cell.imageViewIcon.frame = CGRectMake(0, 0, cell.imageViewIcon.image.size.width, cell.imageViewIcon.image.size.height);
    cell.imageViewIcon.center = iconCenter;
    
    // hide the highlight line for the first cell
    if (indexPath.row > 1) {
        cell.highlightLine.hidden = false;
    }
    
    return cell;
}

@end
