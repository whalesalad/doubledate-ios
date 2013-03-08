//
//  DDAppDelegate.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAppDelegate.h"
#import "DDWelcomeViewController.h"
#import "DDChatViewController.h"
#import "DDAppDelegate+APNS.h"
#import "DDAppDelegate+NavigationMenu.h"
#import "DDAPIController.h"
#import "DDEngagement.h"
#import "DDAuthenticationController.h"
#import "DDUser.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Crashlytics/Crashlytics.h>

@implementation DDAppDelegate

@synthesize userPopover;
@synthesize deviceToken;
@synthesize navigationMenu;
@synthesize navigationMenuExist;
@synthesize apiController;
@synthesize selectedEngagement;
@synthesize topNavigationController;
@synthesize callbackUrl;
@synthesize openedCallbackUrl;
@synthesize products;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [userPopover release];
    [deviceToken release];
    [navigationMenu release];
    [apiController release];
    [selectedEngagement release];
    [callbackUrl release];
    [openedCallbackUrl release];
    [products release];
    [super dealloc];
}

- (UINavigationController*)topNavigationController
{
    UINavigationController *top = (UINavigationController*)self.viewController;
    while (top.presentedViewController)
    {
        //save top view controller
        UIViewController *vc = top.presentedViewController;
        
        //navigation controller to present
        UINavigationController *nc = vc.navigationController;
        
        //check class
        if (!nc && [vc isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *ncToCheck = (UINavigationController*)vc;
            nc = ncToCheck;
        }
        if (!nc && [vc isKindOfClass:[UITabBarController class]])
        {
            UITabBarController *tbcToCheck = (UITabBarController*)vc;
            UIViewController *vcToCheck = [tbcToCheck selectedViewController];
            if (vcToCheck.navigationController)
                nc = vcToCheck.navigationController;
            else if ([vcToCheck isKindOfClass:[UINavigationController class]])
                nc = (UINavigationController*)vcToCheck;
        }
        
        //check if we need to continue
        if (nc)
        {
            top = nc;
            continue;
        }
        else
            break;
    }
    return top;
}

- (void)updateApplicationBadge
{
    DDUser *currentUser = [DDAuthenticationController currentUser];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[currentUser.unreadNotificationsCount intValue]+[currentUser.unreadMessagesCount intValue]+[currentUser.pendingWingsCount intValue]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //init crash reporting
    [Crashlytics startWithAPIKey:@"8f1d9834293a48fdf632da59507bdd08f2842fde"];
    
    //create api controller
    self.apiController = [[[DDAPIController alloc] init] autorelease];
    self.apiController.delegate = self;
    
    //create window
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    //create view controller
    self.viewController = [[[DDNavigationController alloc] initWithRootViewController:[[[DDWelcomeViewController alloc] init] autorelease]] autorelease];

    //attach view controller
    self.window.rootViewController = self.viewController;

    //set view controller delegate
    [(UINavigationController*)self.viewController setDelegate:self];

    //show window
    [self.window makeKeyAndVisible];
    
    //check if opened from remote notification
    if ([[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] isKindOfClass:[NSDictionary class]])
    {
        if ([[[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"callback_url"] isKindOfClass:[NSString class]])
            [self handleNotificationUrl:[[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"callback_url"]];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[FBSession activeSession] handleDidBecomeActive];
    [self sendMyDevice];
    [DDAuthenticationController updateCurrentUser];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"%@ : %@ : %@", url, sourceApplication, annotation);
    return [[FBSession activeSession] handleOpenURL:url];
}

@end
