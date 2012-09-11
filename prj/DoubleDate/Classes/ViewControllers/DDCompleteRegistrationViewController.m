//
//  DDCompleteRegistrationViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDCompleteRegistrationViewController.h"
#import "DDUser.h"
#import "DDAPIController.h"
#import "DDWelcomeViewController.h"
#import "DDAuthenticationController.h"
#import "DDFacebookController.h"

@interface DDCompleteRegistrationViewController ()<DDAPIControllerDelegate>

@end

@implementation DDCompleteRegistrationViewController

@synthesize user;
@synthesize textFieldEmail;
@synthesize textFieldPassword;

- (UIView*)viewForHud
{
    return self.parentViewController.view;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
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
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Almost Done!", nil);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [user release];
    [textFieldEmail release];
    [textFieldPassword release];
    controller_.delegate = nil;
    [controller_ release];
    [super dealloc];
}

#pragma mark -
#pragma comment IB

- (IBAction)joinTouched:(id)sender
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Creating", nil) animated:YES];
    
    //set email and password
    if ([textFieldEmail.text length])
        self.user.email = textFieldEmail.text;
    if ([textFieldPassword.text length])
        self.user.password = textFieldPassword.text;
    
    //create user
    [controller_ createUser:self.user];
}

#pragma mark -
#pragma comment DDAPIControllerDelegate

- (void)createUserSucceed:(DDUser*)u
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Authorizing", nil) animated:NO];
    
    //save password
    u.password = self.user.password;
    
    //save user
    self.user = u;
    
    //authonticate user
    if (u.facebookId)
        [DDAuthenticationController authenticateWithFbId:self.user.facebookId fbToken:[DDFacebookController token] delegate:self];
    else
        [DDAuthenticationController authenticateWithEmail:self.user.email password:self.user.password delegate:self];
}

- (void)createUserDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
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
        [self hideHud:YES];
        
        //start with user
        [(DDWelcomeViewController*)[self viewControllerForClass:[DDWelcomeViewController class]] startWithUser:self.user];
    }
}

- (void)apiDidNotAuthenticate:(NSNotification*)notification
{
    //check for delegate
    if ([notification.userInfo objectForKey:DDAuthenticationControllerAuthenticateUserInfoDelegateKey] == self)
    {
        //hide hude
        [self hideHud:YES];
        
        //start with dummy
        [(DDWelcomeViewController*)[self viewControllerForClass:[DDWelcomeViewController class]] startWithUser:nil];
    }
}

@end
