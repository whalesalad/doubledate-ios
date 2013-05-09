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
#import "DDTools.h"
#import "DDFeedbackViewController.h"
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
    
    //blur the view controller under and save previous values
    self.navigationUnderViewShouldRasterize = self.topNavigationController.view.layer.shouldRasterize;
    self.navigationUnderViewRasterizationScale = self.topNavigationController.view.layer.rasterizationScale;
    self.topNavigationController.view.layer.shouldRasterize = YES;
    self.topNavigationController.view.layer.rasterizationScale = self.topNavigationController.view.layer.rasterizationScale * 0.5f;
    
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
        dim.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8f];
        dim.alpha = 0;
        [mainView addSubview:dim];
        
        //add button under table view
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, dim.frame.size.width, dim.frame.size.height);
        [button addTarget:self action:@selector(dismissNavigationMenu) forControlEvents:UIControlEventTouchUpInside];
        [dim addSubview:button];
        
        //add table view
        DDNavigationMenu *table = [[[DDNavigationMenu alloc] init] autorelease];
        table.center = CGPointMake(table.center.x, table.center.y - table.frame.size.height);
                
        //add view under table
        UIView *viewUnderTable = [[[UIView alloc] initWithFrame:table.frame] autorelease];
        viewUnderTable.tag = kTagNavigationMenuTable;
        viewUnderTable.backgroundColor = [UIColor clearColor];
        viewUnderTable.layer.cornerRadius = 6;
        viewUnderTable.clipsToBounds = YES;
        [mainView addSubview:viewUnderTable];
        
        //re-layout table
        table.frame = viewUnderTable.bounds;
        [viewUnderTable addSubview:table];
        
        //add shadow
        UIImageView *shadow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-menu-inner-shadow.png"]] autorelease];
        shadow.frame = CGRectMake(0, 0, shadow.frame.size.width, shadow.frame.size.height);
        [mainView addSubview:shadow];
        
        // add fake button for sending feedback
        UIButton *feedbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *feedbackButtonImage = [UIImage imageNamed:@"feedback-button.png"];
        
        [feedbackButton setTitle:NSLocalizedString(@"Send Us Feedback", @"Text for Send Feedback button below menu") forState:UIControlStateNormal];
        feedbackButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
        feedbackButton.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5f];
        feedbackButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        feedbackButton.titleEdgeInsets = UIEdgeInsetsMake(1, 40, 0, 0);
        
        [feedbackButton setBackgroundImage:[DDTools resizableImageFromImage:feedbackButtonImage] forState:UIControlStateNormal];
        
        feedbackButton.frame = CGRectMake(0, 0, feedbackButtonImage.size.width, feedbackButtonImage.size.height);
        [dim addSubview:feedbackButton];
        feedbackButton.center = CGPointMake(dim.frame.size.width/2, dim.frame.size.height - 40);
        
        [feedbackButton addTarget:self action:@selector(feedbackTouched) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //animate
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        UIView *viewBar = [self.navigationMenu viewWithTag:kTagNavigationMenuBar];
        viewBar.alpha = 1;
        UIView *viewDim = [self.navigationMenu viewWithTag:kTagNavigationMenuDim];
        [viewDim setAlpha:1.0f];
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
    
    //unblur the view controller
    self.topNavigationController.view.layer.shouldRasterize = self.navigationUnderViewShouldRasterize;
    self.topNavigationController.view.layer.rasterizationScale = self.navigationUnderViewRasterizationScale;
    
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

- (void)feedbackTouched
{
    //dismiss menu
    [self dismissNavigationMenu];
    
    //create feedback view controller
    DDFeedbackViewController *vc = [[[DDFeedbackViewController alloc] init] autorelease];
    
    //wrap view controller into the navigaton controller
    UINavigationController *nc = [[[DDNavigationController alloc] initWithRootViewController:vc] autorelease];
    
    //present view controller
    [self.topNavigationController presentViewController:nc animated:YES completion:^{
    }];
}

#pragma mark -
#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self dismissNavigationMenu];
}

@end
