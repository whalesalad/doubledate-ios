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
#import <QuartzCore/QuartzCore.h>

@implementation DDViewController

@synthesize viewAfterAppearing;

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
    {
        [self hideHud:YES];
        hud = nil;
    }
    
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
    
    //bring to parent
    [hud.superview bringSubviewToFront:hud];
}

- (void)hideHud:(BOOL)animated
{
    //get hud
    MBProgressHUD *hud = [MBProgressHUD HUDForView:[self viewForHud]];
    
    //remove hud
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:animated];
}

- (BOOL)isHudExist
{
    return [MBProgressHUD HUDForView:[self viewForHud]] != nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    //show view after appearing
    [self.viewAfterAppearing setHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //make customization
    [self customize];
}

- (void)customize
{
    //load dictionay
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Design" ofType:@"plist"]];
    
    //read each class
    for (NSString *key in [dictionary allKeys])
    {
        //check class
        Class curClass = NSClassFromString(key);
        
        //check if it's the same
        if ([self isKindOfClass:curClass])
        {
            //check navigation bar
            NSDictionary *dicUINavigationBar = [[dictionary objectForKey:key] objectForKey:@"UINavigationBar"];
            if ([dicUINavigationBar objectForKey:@"color"])
            {
                NSNumber *r = [[dicUINavigationBar objectForKey:@"color"] objectForKey:@"r"];
                NSNumber *g = [[dicUINavigationBar objectForKey:@"color"] objectForKey:@"g"];
                NSNumber *b = [[dicUINavigationBar objectForKey:@"color"] objectForKey:@"b"];
                NSNumber *a = [[dicUINavigationBar objectForKey:@"color"] objectForKey:@"a"];
                self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:[r floatValue]/255.0f green:[g floatValue]/255.0f blue:[b floatValue]/255.0f alpha:[a floatValue]/255.0f];
            }
            
            //check layer
            NSDictionary *dicCALayer = [[dictionary objectForKey:key] objectForKey:@"CALayer"];
            if ([dicCALayer objectForKey:@"shadowOffset"])
                self.view.layer.shadowOffset = CGSizeFromString([dicCALayer objectForKey:@"shadowOffset"]);
        }
    }
}

- (UIViewController*)viewControllerForClass:(Class)vcClass inViewController:(UIViewController*)vc
{
    //check dummy
    if (!vc)
        return nil;
    
    //check if already checked
    for (NSNumber *number in buffer_)
    {
        if ([number unsignedIntegerValue] == [vc hash])
            return nil;
    }
    
    //mark as checked
    [buffer_ addObject:[NSNumber numberWithUnsignedInteger:[vc hash]]];
    
    //check self
    if ([vc isKindOfClass:vcClass])
        return vc;
    
    //init value
    UIViewController *ret = nil;
    
    //check parent
    ret = [self viewControllerForClass:vcClass inViewController:vc.parentViewController];
    if (ret)
        return ret;
    
    //check presented
    ret = [self viewControllerForClass:vcClass inViewController:vc.presentedViewController];
    if (ret)
        return ret;
    
    //check presenting
    ret = [self viewControllerForClass:vcClass inViewController:vc.presentingViewController];
    if (ret)
        return ret;
    
    //check navigation controller
    if ([vc isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nc = (UINavigationController*)vc;
        for (UIViewController *v in nc.viewControllers)
        {
            ret = [self viewControllerForClass:vcClass inViewController:v];
            if (ret)
                return ret;
        }
    }
    
    return nil;
}

- (UIViewController*)viewControllerForClass:(Class)vcClass
{
    buffer_ = [[NSMutableArray alloc] init];
    UIViewController *ret = [self viewControllerForClass:vcClass inViewController:self];
    [buffer_ release];
    return ret;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self hideHud:YES];
    [viewAfterAppearing release];
    [super dealloc];
}

@end
