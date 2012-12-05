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

DECLARE_HUD_WITH_PROPERTY(DDViewController, hud_)
DECLARE_API_CONTROLLER_WITH_PROPERTY(DDViewController, apiController_)
DECLARE_BUFFER_WITH_PROPERTY(DDViewController, buffer_)

@interface DDViewController (hidden) <DDAPIControllerDelegate>

@end

@implementation DDViewController

@synthesize backButtonTitle;
@synthesize moveWithKeyboard;

- (void)initSelf
{
    apiController_ = [[DDAPIController alloc] init];
    apiController_.delegate = self;
    
    self.backButtonTitle = NSLocalizedString(@"BACK", nil);
    
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
    self.navigationItem.leftBarButtonItem = [DDBarButtonItem backBarButtonItemWithTitle:self.backButtonTitle target:self action:@selector(backTouched:)];
}

- (void)backTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    apiController_.delegate = nil;
    [apiController_ release];
    [backButtonTitle release];
    [self hideHud:YES];
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
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y - (keyBoardSize.height - self.tabBarController.tabBar.frame.size.height));
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
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y + (keyBoardSize.height - self.tabBarController.tabBar.frame.size.height));
        [UIView commitAnimations];
    }
}

@end
