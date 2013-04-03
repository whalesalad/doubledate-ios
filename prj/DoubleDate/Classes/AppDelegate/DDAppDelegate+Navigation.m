//
//  DDAppDelegate+Navigation.m
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAppDelegate+Navigation.h"
#import "DDMeViewController.h"
#import "DDWingsViewController.h"
#import "DDDoubleDatesViewController.h"
#import "DDEngagementsViewController.h"
#import "DDAppDelegate+NavigationMenu.h"
#import "DDFacebookController.h"
#import "DDNotificationsViewController.h"
#import "DDAppDelegate+APNS.h"
#import "DDAuthenticationController.h"
#import "DDLocationController.h"
#import "BCTabBarController.h"
#import "BCTabBarView.h"

@implementation DDAppDelegate (Navigation)

- (void)loginUser:(DDUser*)user animated:(BOOL)animated
{
    //save current user
    [DDAuthenticationController setCurrentUser:user];
    
    //start searching location
    [DDLocationController startCurrentLocationHandling];
    [DDLocationController updateCurrentLocation];
    
    //set notifications view controller
    DDNotificationsViewController *notificationsViewController = [[[DDNotificationsViewController alloc] init] autorelease];
    notificationsViewController.hidesBottomBarWhenPushed = YES;
    notificationsViewController.shouldShowNavigationMenu = YES;
    
    //set me view controller
    DDMeViewController *meViewController = [[[DDMeViewController alloc] init] autorelease];
    meViewController.user = user;
    meViewController.hidesBottomBarWhenPushed = YES;
    meViewController.shouldShowNavigationMenu = YES;
    
    //set wingman view controller
    DDWingsViewController *wingsViewController = [[[DDWingsViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    wingsViewController.hidesBottomBarWhenPushed = YES;
    wingsViewController.shouldShowNavigationMenu = YES;
    
    //set browse view controller
    DDDoubleDatesViewController *browseViewController = [[[DDDoubleDatesViewController alloc] init] autorelease];
    browseViewController.mode = DDDoubleDatesViewControllerModeAll;
    browseViewController.hidesBottomBarWhenPushed = YES;
    browseViewController.shouldShowNavigationMenu = YES;
    
    //set date view controller
    DDDoubleDatesViewController *myDatesViewController = [[[DDDoubleDatesViewController alloc] init] autorelease];
    myDatesViewController.mode = DDDoubleDatesViewControllerModeMine;
    myDatesViewController.hidesBottomBarWhenPushed = YES;
    myDatesViewController.shouldShowNavigationMenu = YES;
    
    //add messages view controller
    DDEngagementsViewController *messagesViewController = [[[DDEngagementsViewController alloc] init] autorelease];
    messagesViewController.weakParentViewController = messagesViewController;
    messagesViewController.hidesBottomBarWhenPushed = YES;
    messagesViewController.shouldShowNavigationMenu = YES;
    
    //create tab bar controller
    BCTabBarController *tabBarController = [[[BCTabBarController alloc] init] autorelease];
    NSMutableArray *viewControllers = [NSMutableArray array];
    [viewControllers addObject:[[[UINavigationController alloc] initWithRootViewController:notificationsViewController] autorelease]];
    [viewControllers addObject:[[[UINavigationController alloc] initWithRootViewController:meViewController] autorelease]];
    [viewControllers addObject:[[[UINavigationController alloc] initWithRootViewController:wingsViewController] autorelease]];
    [viewControllers addObject:[[[UINavigationController alloc] initWithRootViewController:browseViewController] autorelease]];
    [viewControllers addObject:[[[UINavigationController alloc] initWithRootViewController:myDatesViewController] autorelease]];
    [viewControllers addObject:[[[UINavigationController alloc] initWithRootViewController:messagesViewController] autorelease]];
    tabBarController.viewControllers = viewControllers;
    
    //check each view controller
    for (UINavigationController *nc in viewControllers)
    {
        if ([nc isKindOfClass:[UINavigationController class]])
            nc.delegate = self;
    }
    
    //default is me tab
    tabBarController.selectedIndex = 1;
        
    //go to next view controller
    [self.viewController presentViewController:tabBarController animated:animated completion:^{
        [self performSelector:@selector(checkAndShowCallbackPayload) withObject:nil afterDelay:0];
    }];
}

- (void)checkAndShowCallbackPayload
{
    //check if we have callback to open
    if (self.payload)
    {
        //handle url
        [self handleNotificationPayload:self.payload];
        
        //unset callbacl url
        self.payload = nil;
    }
}

- (void)switchToWingsTab
{
    BCTabBarController *tabBarController = (BCTabBarController*)[self.viewController viewControllerForClass:[BCTabBarController class]];
    [tabBarController setSelectedIndex:2];
}

- (void)logout
{
    //logout on authentication
    [DDAuthenticationController logout];
    
    //logout on facebook
    [[DDFacebookController sharedController] logout];
    
    //finish location updating
    [DDLocationController stopCurrentLocationHandling];
    
    //dismiss ui
    [self.viewController dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
