//
//  DDAppDelegate+Purchase.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAppDelegate+Purchase.h"
#import "UIViewController+Extensions.h"
#import "DDPurchaseViewController.h"

@implementation DDAppDelegate (Purchase)

- (void)presentPurchaseScreen
{
    //show loading hud
    [self.window.rootViewController showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
    
    //request products
    [self.apiController getInAppProducts];
}

#pragma mark api

- (void)getInAppProductsSucceed:(NSArray *)products
{
    //hide hud
    [self.window.rootViewController hideHud:YES];
    
    //present view controller
    DDAppDelegate *appDelegate = (DDAppDelegate*)[[UIApplication sharedApplication] delegate];
    DDPurchaseViewController *vc = [[[DDPurchaseViewController alloc] init] autorelease];
    vc.products = products;
    UINavigationController *nc = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    [[appDelegate topNavigationController] presentViewController:nc animated:YES completion:^{
    }];
}

- (void)getInAppProductsDidFailedWithError:(NSError *)error
{
    //hide hud
    [self.window.rootViewController hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
