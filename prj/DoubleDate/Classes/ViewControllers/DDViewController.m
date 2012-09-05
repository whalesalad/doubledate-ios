//
//  DDViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"
#import "MBProgressHUD.h"
#import "DDAppDelegate.h"

@implementation DDViewController

- (UIView*)viewForHud
{
    return self.view;
}

- (void)showHudWithText:(NSString*)text animated:(BOOL)animated
{
    //get hud
    MBProgressHUD *hud = [MBProgressHUD HUDForView:[self viewForHud]];
    
    //check if we should hide first
    if (hud && animated)
        [self hideHud:YES];
    
    //check if we should just change a text
    if (hud && !animated)
        hud.labelText = text;
    
    //check if no hud
    if (!hud)
    {
        hud = [[[MBProgressHUD alloc] initWithView:[self viewForHud]] autorelease];
        hud.dimBackground = YES;
        hud.labelText = text;
        [[self viewForHud] addSubview:hud];
        [hud show:animated];
    }
}

- (void)hideHud:(BOOL)animated
{
    //get hud
    MBProgressHUD *hud = [MBProgressHUD HUDForView:[self viewForHud]];
    
    //remove hud
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:animated];
}

- (void)dealloc
{
    [super dealloc];
}

@end
