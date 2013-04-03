//
//  DDAppDelegate+NavigationMenu.m
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAppDelegate+NavigationMenu.h"
#import "DDNavigationMenu.h"
#import "DDNavigationMenuTableViewCell.h"
#import "DDBarButtonItem.h"
#import <QuartzCore/QuartzCore.h>

#define kTagNavigationMenuBar 1
#define kTagNavigationMenuDim 2
#define kTagNavigationMenuTable 3

@implementation DDAppDelegate (APNS)

- (void)presentNavigationMenu
{
    //check if already exist
    if (self.navigationMenuExist)
        return;
        
    //set flag
    self.navigationMenuExist = YES;
    
    //remove previous one
    [self.navigationMenu removeFromSuperview];
    self.navigationMenu = [[[UIView alloc] initWithFrame:self.window.bounds] autorelease];
    self.navigationMenu.backgroundColor = [UIColor clearColor];
    [self.window addSubview:self.navigationMenu];
    
    
    {
        //add fake navigation bar
        UINavigationBar *navigationBar = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.window.frame.size.width, 44)] autorelease];
        navigationBar.alpha = 0;
        navigationBar.tag = kTagNavigationMenuBar;
        [navigationBar setBackgroundImage:[UIImage imageNamed:@"nav-background.png"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationMenu addSubview:navigationBar];
        [navigationBar pushNavigationItem:[[[UINavigationItem alloc] initWithTitle:@""] autorelease] animated:NO];
        
        //add left bar button
        DDBarButtonItem *menuButton = [DDBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"nav-menu-btn.png"] target:self action:@selector(dismissNavigationMenu)];
        CGRect menuButtonFrame = menuButton.button.frame;
        menuButtonFrame.size.width += 10;
        menuButton.button.frame = menuButtonFrame;
        [navigationBar topItem].leftBarButtonItem = menuButton;
        
        //set logo
        [[navigationBar topItem] setTitleView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doubledate-navigation-logo.png"]] autorelease]];
    }
    
    {
        //add main view
        UIView *mainView = [[[UIView alloc] initWithFrame:CGRectMake(0, 20+44, self.window.frame.size.width, self.window.frame.size.height-20-44)] autorelease];
        mainView.backgroundColor = [UIColor clearColor];
        mainView.clipsToBounds = YES;
        [self.navigationMenu addSubview:mainView];
        
        //add dim
        UIView *dim = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, mainView.frame.size.height)] autorelease];
        dim.tag = kTagNavigationMenuDim;
        dim.backgroundColor = [UIColor blackColor];
        dim.alpha = 0;
        [mainView addSubview:dim];
        
        //add button under table view
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, dim.frame.size.width, dim.frame.size.height);
        [button addTarget:self action:@selector(dismissNavigationMenu) forControlEvents:UIControlEventTouchUpInside];
        [dim addSubview:button];
        
        //add table view
        DDNavigationMenu *table = [[[DDNavigationMenu alloc] init] autorelease];
        table.tag = kTagNavigationMenuTable;
        table.center = CGPointMake(table.center.x, table.center.y - table.frame.size.height);
        [mainView addSubview:table];
        table.layer.cornerRadius = 6;
        
        //add shadow
        UIImageView *shadow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-menu-inner-shadow.png"]] autorelease];
        shadow.frame = CGRectMake(0, 0, shadow.frame.size.width, shadow.frame.size.height);
        [mainView addSubview:shadow];
    }
    
    //animate
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        UIView *viewBar = [self.navigationMenu viewWithTag:kTagNavigationMenuBar];
        viewBar.alpha = 1;
        UIView *viewDim = [self.navigationMenu viewWithTag:kTagNavigationMenuDim];
        [viewDim setAlpha:0.8f];
        UIView *viewTable = [self.navigationMenu viewWithTag:kTagNavigationMenuTable];
        [viewTable setCenter:CGPointMake(viewTable.center.x, viewTable.center.y + viewTable.frame.size.height - [DDNavigationMenuTableViewCell height])];
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
    UIView *viewBar = [self.navigationMenu viewWithTag:kTagNavigationMenuBar];
    UIView *viewDim = [self.navigationMenu viewWithTag:kTagNavigationMenuDim];
    UIView *viewTable = [self.navigationMenu viewWithTag:kTagNavigationMenuTable];
    [UIView animateWithDuration:0.1f animations:^{
        [viewTable setCenter:CGPointMake(viewTable.center.x, viewTable.center.y + 10)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [viewBar setAlpha:0];
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
