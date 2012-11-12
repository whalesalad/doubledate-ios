//
//  DDViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"
#import "DDViewController+Design.h"
#import "MBProgressHUD.h"
#import "DDAppDelegate.h"
#import "DDAPIController.h"
#import "DDBarButtonItem.h"
#import <QuartzCore/QuartzCore.h>
#import "DDTools.h"

#define kTagHud 34985123

@interface DDViewController (hidden) <DDAPIControllerDelegate>

@end

@implementation DDViewController

@synthesize viewAfterAppearing;
@synthesize apiController=apiController_;

- (void)initSelf
{
    apiController_ = [[DDAPIController alloc] init];
    apiController_.delegate = self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initSelf];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        [self initSelf];
    }
    return self;
}

- (UIView*)viewForHud
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    return [windows objectAtIndex:[windows count]-1];
}

- (MBProgressHUD*)HUDForView:(UIView*)view
{
    /*MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (hud.tag == 34985123)
        return hud;
    return nil;*/
    return hud_;
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
        [hud_ release];
        hud_ = nil;
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
        hud.tag = kTagHud;
        [[self viewForHud] addSubview:hud];
        [hud show:animated];
        
        //save own hud
        hud_ = [hud retain];
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
    [hud_ release];
    hud_ = nil;
}

- (BOOL)isHudExist
{
    return [self HUDForView:[self viewForHud]] != nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set background color
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dd-pinstripe-background"]];
    
    //customize navigation bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav-background.png"] forBarMetrics:UIBarMetricsDefault];
    
    //customize left button
    self.navigationItem.leftBarButtonItem = [DDBarButtonItem backBarButtonItemWithTitle:NSLocalizedString(@"Back", nil) target:self action:@selector(backTouched:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //show view after appearing
    [self.viewAfterAppearing setHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //make customization
    [self customize];
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

- (void)backTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView*)viewForHeaderWithMainText:(NSString*)mainText detailedText:(NSString*)detailedText
{
    //set general view
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)] autorelease];
    view.backgroundColor = [UIColor clearColor];
    
    //add label
    UILabel *labelMain = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    labelMain.font = [DDTools boldAvenirFontOfSize:14];
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
        labelDetailed.font = [DDTools avenirFontOfSize:11];
        labelDetailed.textColor = [UIColor grayColor];
        labelDetailed.text = detailedText;
        [labelDetailed sizeToFit];
        labelDetailed.frame = CGRectMake(labelMain.frame.origin.x+labelMain.frame.size.width+8, labelMain.frame.origin.y+2, labelDetailed.frame.size.width, labelMain.frame.size.height);
        labelDetailed.backgroundColor = [UIColor clearColor];
        [view addSubview:labelDetailed];
    }
    
    return view;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    apiController_.delegate = nil;
    [apiController_ release];
    [self hideHud:YES];
    [viewAfterAppearing release];
    [super dealloc];
}

@end
