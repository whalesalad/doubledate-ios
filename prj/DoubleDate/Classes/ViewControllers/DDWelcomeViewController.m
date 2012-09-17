//
//  DDWelcomeViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDWelcomeViewController.h"
#import "DDFacebookController.h"
#import "MBProgressHUD.h"
#import <FacebookSDK/FacebookSDK.h>
#import <RestKit/RestKit.h>
#import <SBJson/SBJson.h>
#import "DDBasicInfoViewController.h"
#import "DDTools.h"
#import "DDAuthenticationController.h"
#import "DDRequestsController.h"
#import "DDAPIController.h"
#import "DDLoginViewController.h"
#import "DDUser.h"
#import "DDMeViewController.h"

#define kTagEmailActionSheet 1

@interface DDWelcomeViewController ()<UIActionSheetDelegate, DDAPIControllerDelegate>

- (void)joinWithEmail;
- (void)loginWithEmail;

- (void)registerWithUser:(DDUser*)user;

@end

@implementation DDWelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidLogin:) name:DDFacebookControllerSessionDidLoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidNotLogin:) name:DDFacebookControllerSessionDidNotLoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiDidAuthenticate:) name:DDAuthenticationControllerAuthenticateDidSucceesNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiDidNotAuthenticate:) name:DDAuthenticationControllerAuthenticateDidFailedNotification object:nil];
        
        controller_ = [[DDAPIController alloc] init];
        controller_.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)dealloc
{
    controller_.delegate = nil;
    [controller_ release];
    [super dealloc];
}

#pragma mark -
#pragma comment IB

- (IBAction)facebookTouched:(id)sender
{
    //start facebook
    [[DDFacebookController sharedController] login];
}

- (IBAction)emailTouched:(id)sender
{
    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Log In to DoubleDate", nil), NSLocalizedString(@"Sign Up with Email", nil), nil] autorelease];
    sheet.tag = kTagEmailActionSheet;
    [sheet showInView:self.view];
}

#pragma mark -
#pragma comment UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            if (actionSheet.tag == kTagEmailActionSheet)
                [self loginWithEmail];
            break;
        case 1:
            if (actionSheet.tag == kTagEmailActionSheet)
                [self joinWithEmail];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma comment other

- (void)joinWithEmail
{
    [self registerWithUser:nil];
}

- (void)loginWithEmail
{
    //login with email and address
    [self.navigationController presentModalViewController:[[[UINavigationController alloc] initWithRootViewController:[[[DDLoginViewController alloc] init] autorelease]] autorelease] animated:YES];
}

- (void)registerWithUser:(DDUser*)user
{
    //go to next view controller
    DDBasicInfoViewController *viewController = [[[DDBasicInfoViewController alloc] init] autorelease];
    viewController.user = user;
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    [self.navigationController presentModalViewController:navigationController animated:YES];
}

#pragma mark -
#pragma comment Facebook

- (void)fbDidLogin:(NSNotification*)notification
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
    
    //try to authonticate with facebook
    [DDAuthenticationController authenticateWithFbToken:[DDFacebookController token] delegate:self];
}

- (void)fbDidNotLogin:(NSNotification*)notification
{
    //extract error
    NSError *error = [[notification userInfo] objectForKey:DDFacebookControllerSessionDidNotLoginUserInfoErrorKey];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma comment API

- (void)apiDidAuthenticate:(NSNotification*)notification
{
    //check for delegate
    if ([notification.userInfo objectForKey:DDAuthenticationControllerAuthenticateUserInfoDelegateKey] == self)
    {
        //hide hud
        [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:NO];
    
        //extract information about me
        [controller_ getMe];
    }
}

- (void)apiDidNotAuthenticate:(NSNotification*)notification
{
    //check for delegate
    if ([notification.userInfo objectForKey:DDAuthenticationControllerAuthenticateUserInfoDelegateKey] == self)
    {
        //if user is not exist fetch new data
        if ([[[notification userInfo] objectForKey:DDAuthenticationControllerAuthenticateDidFailedUserInfoResponseCodeKey] intValue] == 404)
        {
            //show hud
            [self showHudWithText:NSLocalizedString(@"Fetching User", nil) animated:NO];
            
            //request information about the user
            [controller_ requeFacebookUserForToken:[DDFacebookController token]];
        }
        else
        {
            //hide hude
            [self hideHud:YES];
            
            //try to get error
            NSError *error = [[notification userInfo] objectForKey:DDAuthenticationControllerAuthenticateDidFailedUserInfoErrorKey];
            if (error)
                [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
        }
    }
}

#pragma mark -
#pragma comment DDAPIControllerDelegate

- (void)getMeDidSucceed:(DDUser*)me
{
    //hide hude
    [self hideHud:YES];
    
    //start with user
    [self startWithUser:me];
}

- (void)getMeDidFailedWithError:(NSError*)error
{
    //hide hude
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)requestFacebookUserSucceed:(DDUser*)user
{
    //hide hude
    [self hideHud:YES];
    
    //register user
    [self registerWithUser:user];
}

- (void)requestFacebookDidFailedWithError:(NSError*)error
{
    //hide hude
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma comment other

- (void)startWithUser:(DDUser*)user
{
    //dismiss all modal view controllers
    [self dismissModalViewControllerAnimated:YES];
    
    //check user
    if (user)
    {
        //set me view controller
        UIImage *imageMe = nil;
        if ([user.gender isEqualToString:DDUserGenderMale])
            imageMe = [UIImage imageNamed:@"profile-male-tab-bar.png"];
        else if ([user.gender isEqualToString:DDUserGenderFemale])
            imageMe = [UIImage imageNamed:@"woman-tab-bar"];
        DDMeViewController *meViewController = [[[DDMeViewController alloc] init] autorelease];
        meViewController.user = user;
        meViewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Me", nil) image:imageMe tag:0] autorelease];
        
        //create tab bar controller
        UITabBarController *tabBarController = [[[UITabBarController alloc] init] autorelease];
        tabBarController.viewControllers = [NSArray arrayWithObjects:[[[UINavigationController alloc] initWithRootViewController:meViewController] autorelease], nil];
        
        //go to next view controller
        [self.navigationController pushViewController:tabBarController animated:NO];
    }
}

@end
