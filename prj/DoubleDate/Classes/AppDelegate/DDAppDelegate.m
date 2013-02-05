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
#import <FacebookSDK/FacebookSDK.h>

@implementation DDAppDelegate

@synthesize userPopover;
@synthesize deviceToken;
@synthesize navigationMenu;
@synthesize navigationMenuExist;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [userPopover release];
    [deviceToken release];
    [navigationMenu release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
//    DDChatViewController *vc = [[[DDChatViewController alloc] init] autorelease];
//    UITabBarController *t = [[[UITabBarController alloc] init] autorelease];
//    t.viewControllers = [NSArray arrayWithObject:[[[UINavigationController alloc] initWithRootViewController:vc] autorelease]];
//    self.viewController = t;
//    vc.weakParentViewController = vc;
    self.viewController = [[[UINavigationController alloc] initWithRootViewController:[[[DDWelcomeViewController alloc] initWithNibName:@"DDWelcomeViewController" bundle:nil] autorelease]] autorelease];
    self.window.rootViewController = self.viewController;
    [(UINavigationController*)self.viewController setDelegate:self];
    [self.window makeKeyAndVisible];
    
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSession activeSession] handleOpenURL:url];
}

@end
