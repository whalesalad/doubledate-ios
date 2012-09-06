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

@interface DDWelcomeViewController ()<UIActionSheetDelegate, DDAPIControllerDelegate>

- (void)joinWithFacebook;
- (void)joinWithEmail;

@end

@implementation DDWelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidLogin:) name:DDFacebookControllerSessionDidLoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidNotLogin:) name:DDFacebookControllerSessionDidNotLoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidGetMe:) name:DDFacebookControllerSessionDidGetMeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidNotGetMe:) name:DDFacebookControllerSessionDidNotGetMeNotification object:nil];
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

- (IBAction)signupTouched:(id)sender
{
    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Join with Facebook", nil), NSLocalizedString(@"Join with Email", nil), nil] autorelease];
    [sheet showInView:self.view];
}

- (IBAction)loginTouched:(id)sender
{
    
}


#pragma mark -
#pragma comment UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self joinWithFacebook];
            break;
        case 1:
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma comment other

- (void)joinWithFacebook
{
    //start facebook
    [[DDFacebookController sharedController] login];
}

- (void)joinWithEmail
{
    
}

#pragma mark -
#pragma comment Facebook

- (void)fbDidLogin:(NSNotification*)notification
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Getting Information", nil) animated:YES];
    
    //request information about me
    [[DDFacebookController sharedController] requestMe];
}

- (void)fbDidNotLogin:(NSNotification*)notification
{
    //extract error
    NSError *error = [[notification userInfo] objectForKey:DDFacebookControllerSessionDidNotLoginUserInfoErrorKey];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)fbDidGetMe:(NSNotification*)notification
{
    //change hud
    [self showHudWithText:NSLocalizedString(@"Authenticating", nil) animated:NO];
    
    //extract user information from facebook
    id<FBGraphUser> user = (id<FBGraphUser>)[[notification userInfo] objectForKey:DDFacebookControllerSessionDidGetMeUserInfoObjectKey];
    
    //authonticate user
    [DDAuthenticationController authenticateWithFbId:[user id] fbToken:[DDFacebookController token]];
}

- (void)fbDidNotGetMe:(NSNotification*)notification
{
    //hide hud
    [self hideHud:YES];
    
    //extract error
    NSError *error = [[notification userInfo] objectForKey:DDFacebookControllerSessionDidNotGetMeUserInfoErrorKey];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma comment API

- (void)apiDidAuthenticate:(NSNotification*)notification
{
    //hide hude
    [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:NO];
    
    //extract information about me
    [controller_ getMe];
}

- (void)apiDidNotAuthenticate:(NSNotification*)notification
{
    //hide hude
    [self hideHud:YES];
    
    //try to get error
    NSError *error = [[notification userInfo] objectForKey:DDAuthenticationControllerAuthenticateDidFailedUserInfoErrorKey];
    if (error)
        [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma comment DDAPIControllerDelegate

- (void)getMeDidSucceed:(DDUser*)me
{
    //hide hude
    [self hideHud:YES];
    
    //go to next view controller
    DDBasicInfoViewController *viewController = [[[DDBasicInfoViewController alloc] init] autorelease];
    viewController.user = me;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)getMeDidFailedWithError:(NSError*)error
{
    //hide hude
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
