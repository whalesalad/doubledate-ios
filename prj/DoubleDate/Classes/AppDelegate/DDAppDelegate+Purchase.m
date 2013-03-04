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
#import "DDStoreKitController.h"
#import "DDInAppProduct.h"

@interface DDAppDelegate (PurchaseHidden) <DDStoreKitControllerDelegate>
@end

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
    //save products
    self.products = products;
    
    //create request
    NSMutableSet *pids = [NSMutableSet set];
    for (DDInAppProduct *product in products)
        [pids addObject:product.identifier];

    //set delegate
    [[DDStoreKitController sharedController] setDelegate:self];
    
    //request
    [[DDStoreKitController sharedController] requestProductDataWithPids:pids];
}

- (void)getInAppProductsDidFailedWithError:(NSError *)error
{
    //hide hud
    [self.window.rootViewController hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark store

- (void)productsReceived:(NSArray*)products
{
    //unset delegate
    [[DDStoreKitController sharedController] setDelegate:nil];
    
    //hide hud
    [self.window.rootViewController hideHud:YES];
    
    //present view controller
    DDAppDelegate *appDelegate = (DDAppDelegate*)[[UIApplication sharedApplication] delegate];
    DDPurchaseViewController *vc = [[[DDPurchaseViewController alloc] init] autorelease];
    vc.products = self.products;
    UINavigationController *nc = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    [[appDelegate topNavigationController] presentViewController:nc animated:YES completion:^{
    }];
}

- (void)productsReceivingFailed:(NSError*)error
{
    //unset delegate
    [[DDStoreKitController sharedController] setDelegate:nil];
    
    //hide hud
    [self.window.rootViewController hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
