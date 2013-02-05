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
#import "DDAPIController.h"
#import "DDBarButtonItem.h"
#import <QuartzCore/QuartzCore.h>
#import "DDTools.h"
#import "UIViewController+Extensions.h"
#import "DDAppDelegate+NavigationMenu.h"

DECLARE_HUD_WITH_PROPERTY(DDViewController, hud_)
DECLARE_API_CONTROLLER_WITH_PROPERTY(DDViewController, apiController_)
DECLARE_BUFFER_WITH_PROPERTY(DDViewController, buffer_)

@interface DDViewController (hidden) <DDAPIControllerDelegate>

@end

@implementation DDViewController

@synthesize backButtonTitle;
@synthesize moveWithKeyboard;
@synthesize shouldShowNavigationMenu;

- (void)initSelf
{
    apiController_ = [[DDAPIController alloc] init];
    apiController_.delegate = self;
    
    self.backButtonTitle = NSLocalizedString(@"Back", nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set background color
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dd-pinstripe-background"]];
    
    //customize navigation bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav-background.png"] forBarMetrics:UIBarMetricsDefault];
    
    //customize left button
    if ([self shouldShowNavigationMenu])
        self.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"nav-menu-btn.png"] target:self action:@selector(menuTouched:)];
    else
        self.navigationItem.leftBarButtonItem = [DDBarButtonItem backBarButtonItemWithTitle:self.backButtonTitle target:self action:@selector(backTouched:)];
}

- (void)backTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)menuTouched:(id)sender
{
    DDAppDelegate *appDelegate = (DDAppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isNavigationMenuExist])
        [appDelegate dismissNavigationMenu];
    else
        [appDelegate presentNavigationMenu];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [backButtonTitle release];
    [self hideHud:YES];
    self.apiController.delegate = nil;
    self.apiController = nil;
    self.hud = nil;
    self.buffer = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark UIKeyboard

- (void)keyboardWillShowNotification:(NSNotification*)notification
{
    //check if we need to move together with keyboard
    if (self.moveWithKeyboard)
    {
        //save moved flag
        movedWithKeyboard_ = YES;
        
        //apply change
        CGSize keyBoardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        [UIView beginAnimations:@"KeyboardWillShow" context:nil];
        [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
        self.navigationController.view.center = CGPointMake(self.navigationController.view.center.x, self.navigationController.view.center.y - (keyBoardSize.height - self.tabBarController.tabBar.frame.size.height));
        [UIView commitAnimations];
    }
    else
        movedWithKeyboard_ = NO;
}

- (void)keyboardWillHideNotification:(NSNotification*)notification
{
    //cehck if we need to hide
    if (movedWithKeyboard_)
    {
        //apply change
        CGSize keyBoardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        [UIView beginAnimations:@"KeyboardWillHide" context:nil];
        [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
        self.navigationController.view.center = CGPointMake(self.navigationController.view.center.x, self.navigationController.view.center.y + (keyBoardSize.height - self.tabBarController.tabBar.frame.size.height));
        [UIView commitAnimations];
    }
}

@end
