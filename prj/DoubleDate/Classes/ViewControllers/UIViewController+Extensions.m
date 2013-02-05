//
//  UIViewController+Extensions.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "UIViewController+Extensions.h"
#import "MBProgressHUD.h"
#import "DDAPIController.h"
#import "DDTools.h"

@implementation UIViewController (HUD)

- (void)setHud:(MBProgressHUD*)hud
{
}

- (MBProgressHUD*)hud
{
    return nil;
}

- (UIView*)viewForHud
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    return [windows objectAtIndex:[windows count]-1];
}

- (MBProgressHUD*)HUDForView:(UIView*)view
{
    return self.hud;
}

- (void)showHudWithText:(NSString*)text animated:(BOOL)animated
{
    //get hud
    MBProgressHUD *hud = [self HUDForView:[self viewForHud]];
    
    //check if we should hide first
    if (hud && animated)
    {
        //hide hud
        [self hideHud:YES];
        hud = nil;
        
        //unset own hud
        self.hud = nil;
    }
    
    //check if we should just change a text
    if (hud && !animated)
        hud.labelText = text;
    
    //check if no hud
    if (!hud)
    {
        //add hud
        hud = [[[MBProgressHUD alloc] initWithView:[self viewForHud]] autorelease];
        hud.dimBackground = YES;
        hud.labelText = text;
        [[self viewForHud] addSubview:hud];
        [hud show:animated];
        
        //save own hud
        self.hud = hud;
    }
    
    //bring to parent
    [hud.superview bringSubviewToFront:hud];
}

- (void)hideHud:(BOOL)animated
{
    //get hud
    MBProgressHUD *hud = [self HUDForView:[self viewForHud]];
    
    //remove hud
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:animated];
    
    //unset own hud
    self.hud = nil;
}

- (BOOL)isHudExist
{
    return [self HUDForView:[self viewForHud]] != nil;
}

- (void)showCompletedHudWithText:(NSString *)text
{
    //add hud
    MBProgressHUD *hud = [[[MBProgressHUD alloc] initWithView:[self viewForHud]] autorelease];
    hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = text;
    [[self viewForHud] addSubview:hud];
    [hud show:YES];
    [hud hide:YES afterDelay:2];
}

@end

@implementation UIViewController (API)

- (void)setApiController:(DDAPIController*)apiController
{
}

- (DDAPIController*)apiController
{
    return nil;
}

@end

@implementation UIViewController (Other)

- (void)setBuffer:(NSMutableArray*)v
{
}

- (NSMutableArray*)buffer
{
    return nil;
}

- (UIViewController*)viewControllerForClass:(Class)vcClass inViewController:(UIViewController*)vc
{
    //check dummy
    if (!vc)
        return nil;
    
    //check if already checked
    for (NSNumber *number in self.buffer)
    {
        if ([number unsignedIntegerValue] == [vc hash])
            return nil;
    }
    
    //mark as checked
    [self.buffer addObject:[NSNumber numberWithUnsignedInteger:[vc hash]]];
    
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
    self.buffer = [[NSMutableArray alloc] init];
    UIViewController *ret = [self viewControllerForClass:vcClass inViewController:self];
    self.buffer = nil;
    return ret;
}

- (UIView*)viewForHeaderWithMainText:(NSString*)mainText detailedText:(NSString*)detailedText
{
    //set general view
    UIImage *backgroundImage = [DDTools resizableImageFromImage:[UIImage imageNamed:@"dark-tableview-header.png"]];
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, backgroundImage.size.height)] autorelease];
    view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    //add label
    UILabel *labelMain = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    DD_F_HEADER_MAIN(labelMain);
    labelMain.textColor = [UIColor whiteColor];
    labelMain.text = mainText;
    [labelMain sizeToFit];
    labelMain.frame = CGRectMake(18, 1, labelMain.frame.size.width, labelMain.frame.size.height);
    labelMain.backgroundColor = [UIColor clearColor];
    [view addSubview:labelMain];
    
    //add label
    if ([detailedText length])
    {
        UILabel *labelDetailed = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        DD_F_HEADER_DETAILED(labelDetailed);
        labelDetailed.textColor = [UIColor grayColor];
        labelDetailed.text = detailedText;
        [labelDetailed sizeToFit];
        labelDetailed.frame = CGRectMake(labelMain.frame.origin.x+labelMain.frame.size.width+8, labelMain.frame.origin.y+2, labelDetailed.frame.size.width, labelMain.frame.size.height);
        labelDetailed.backgroundColor = [UIColor clearColor];
        [view addSubview:labelDetailed];
    }
    
    return view;
}

- (UIView*)oldStyleViewForHeaderWithMainText:(NSString*)mainText detailedText:(NSString*)detailedText
{
    //set general view
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)] autorelease];
    view.backgroundColor = [UIColor clearColor];
    
    //add label
    UILabel *labelMain = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    DD_F_HEADER_MAIN(labelMain);
    labelMain.textColor = [UIColor grayColor];
    labelMain.text = mainText;
    [labelMain sizeToFit];
    labelMain.frame = CGRectMake(22, 18, labelMain.frame.size.width, labelMain.frame.size.height);
    labelMain.backgroundColor = [UIColor clearColor];
    [view addSubview:labelMain];
    
    //add label
    if ([detailedText length])
    {
        UILabel *labelDetailed = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        DD_F_HEADER_DETAILED(labelDetailed);
        labelDetailed.textColor = [UIColor grayColor];
        labelDetailed.text = detailedText;
        [labelDetailed sizeToFit];
        labelDetailed.frame = CGRectMake(labelMain.frame.origin.x+labelMain.frame.size.width+8, labelMain.frame.origin.y+2, labelDetailed.frame.size.width, labelMain.frame.size.height);
        labelDetailed.backgroundColor = [UIColor clearColor];
        [view addSubview:labelDetailed];
    }
    
    return view;
}

- (UIView*)viewForNavigationBarWithMainText:(NSString*)mainText detailedText:(NSString*)detailedText
{
    //set general view
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    view.backgroundColor = [UIColor clearColor];
    
    //add label
    UILabel *labelMain = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    DD_F_NAVIGATION_HEADER_MAIN(labelMain);
    labelMain.text = mainText;
    labelMain.backgroundColor = [UIColor clearColor];
    labelMain.textAlignment = NSTextAlignmentCenter;
    labelMain.frame = CGRectMake(0, 2, 320, 24);
    [view addSubview:labelMain];
    
    //add detailed
    UILabel *labelDetailed = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    DD_F_NAVIGATION_HEADER_DETAILED(labelDetailed);
    labelDetailed.text = detailedText;
    labelDetailed.backgroundColor = [UIColor clearColor];
    labelDetailed.textAlignment = NSTextAlignmentCenter;
    labelDetailed.frame = CGRectMake(0, 26, 320, 16);
    [view addSubview:labelDetailed];
    
    return view;
}

@end

@implementation UIViewController (NavigationMenu)

- (void)setNavigationMenu:(UIView *)v
{
}

- (UIView*)navigationMenu
{
    return nil;
}

#define kTagNavigationMenuDim 1
#define kTagNavigationMenuTable 2

- (void)presentNavigationMenu
{    
    //create navigation menu
    [self.navigationMenu removeFromSuperview];
    self.navigationMenu = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
    self.navigationMenu.backgroundColor = [UIColor clearColor];
    self.navigationMenu.clipsToBounds = YES;
    [self.view addSubview:self.navigationMenu];
    
    //add dim
    UIView *dim = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.navigationMenu.frame.size.width, self.navigationMenu.frame.size.height)] autorelease];
    dim.tag = kTagNavigationMenuDim;
    dim.backgroundColor = [UIColor blackColor];
    dim.alpha = 0;
    [self.navigationMenu addSubview:dim];
    
    //add tble view
    UIView *table = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.navigationMenu.frame.size.width, 80)] autorelease];
    table.tag = kTagNavigationMenuTable;
    table.backgroundColor = [UIColor redColor];
    table.center = CGPointMake(table.center.x, table.center.y - 80);
    [self.navigationMenu addSubview:table];
    
    //animate
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionBeginFromCurrentState  animations:^{
        UIView *viewDim = [self.navigationMenu viewWithTag:kTagNavigationMenuDim];
        [viewDim setAlpha:0.5f];
        UIView *viewTable = [self.navigationMenu viewWithTag:kTagNavigationMenuTable];
        [viewTable setCenter:CGPointMake(viewTable.center.x, viewTable.center.y + 80)];
    } completion:^(BOOL finished) {
    }];
}

- (void)dismissNavigationMenu
{
    //animate
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        UIView *viewDim = [self.navigationMenu viewWithTag:kTagNavigationMenuDim];
        [viewDim setAlpha:0];
        UIView *viewTable = [self.navigationMenu viewWithTag:kTagNavigationMenuTable];
        [viewTable setCenter:CGPointMake(viewTable.center.x, viewTable.center.y - 80)];
    } completion:^(BOOL finished) {
        [self.navigationMenu removeFromSuperview];
        self.navigationMenu = nil;
    }];
}

- (BOOL)isNavigationMenuPresented
{
    return self.navigationMenu != nil;
}

@end
