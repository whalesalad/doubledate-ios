//
//  DDAppDelegate+NavigationMenu.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAppDelegate+NavigationMenu.h"
#import "DDNavigationMenu.h"
#import "DDNavigationMenuTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

#define kTagNavigationMenuDim 1
#define kTagNavigationMenuTable 2

@implementation DDAppDelegate (APNS)

- (void)presentNavigationMenu
{
    //check if already exist
    if (self.navigationMenuExist)
        return;
    
    //set flag
    self.navigationMenuExist = YES;
    
    //create navigation menu
    [self.navigationMenu removeFromSuperview];
    self.navigationMenu = [[[UIView alloc] initWithFrame:CGRectMake(0, 20+44, self.window.frame.size.width, self.window.frame.size.height-20-44)] autorelease];
    self.navigationMenu.backgroundColor = [UIColor clearColor];
    self.navigationMenu.clipsToBounds = YES;
    [self.window addSubview:self.navigationMenu];
    
    //add dim
    UIView *dim = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.navigationMenu.frame.size.width, self.navigationMenu.frame.size.height)] autorelease];
    dim.tag = kTagNavigationMenuDim;
    dim.backgroundColor = [UIColor blackColor];
    dim.alpha = 0;
    [self.navigationMenu addSubview:dim];
    
    //add button under table view
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, dim.frame.size.width, dim.frame.size.height);
    [button addTarget:self action:@selector(dismissNavigationMenu) forControlEvents:UIControlEventTouchUpInside];
    [dim addSubview:button];
    
    //add table view
    DDNavigationMenu *table = [[[DDNavigationMenu alloc] init] autorelease];
    table.tag = kTagNavigationMenuTable;
    table.center = CGPointMake(table.center.x, table.center.y - table.frame.size.height);
    [self.navigationMenu addSubview:table];
    table.layer.cornerRadius = 6;
    
    //add shadow
    UIImageView *shadow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-menu-inner-shadow.png"]] autorelease];
    shadow.frame = CGRectMake(0, 0, shadow.frame.size.width, shadow.frame.size.height);
    [self.navigationMenu addSubview:shadow];
    
    //animate
    [UIView animateWithDuration:0.25f animations:^{
        UIView *viewDim = [self.navigationMenu viewWithTag:kTagNavigationMenuDim];
        [viewDim setAlpha:0.5f];
        UIView *viewTable = [self.navigationMenu viewWithTag:kTagNavigationMenuTable];
        [viewTable setCenter:CGPointMake(viewTable.center.x, viewTable.center.y + table.frame.size.height - [DDNavigationMenuTableViewCell height])];
    } completion:^(BOOL finished) {
    }];
}

- (void)dismissNavigationMenu
{
    //check if not exist
    if (!self.navigationMenuExist)
        return;
    
    //unset flag
    self.navigationMenuExist = NO;
    
    //animate
    UIView *viewDim = [self.navigationMenu viewWithTag:kTagNavigationMenuDim];
    UIView *viewTable = [self.navigationMenu viewWithTag:kTagNavigationMenuTable];
    [UIView animateWithDuration:0.1f animations:^{
        [viewTable setCenter:CGPointMake(viewTable.center.x, viewTable.center.y + 10)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [viewDim setAlpha:0];
            [viewTable setCenter:CGPointMake(viewTable.center.x, viewTable.center.y - viewTable.frame.size.height + [DDNavigationMenuTableViewCell height])];
        } completion:^(BOOL finished) {
            [self.navigationMenu removeFromSuperview];
            self.navigationMenu = nil;
        }];
    }];
}

- (BOOL)isNavigationMenuExist
{
    return self.navigationMenuExist;
}

#pragma mark -
#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self dismissNavigationMenu];
}

@end
