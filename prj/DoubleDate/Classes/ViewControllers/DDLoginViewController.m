//
//  DDLoginViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 11.09.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDLoginViewController.h"
#import "DDAuthenticationController.h"
#import "DDAPIController.h"
#import "DDWelcomeViewController.h"
#import "DDBarButtonItem.h"

@interface DDLoginViewController ()<DDAPIControllerDelegate>

@end

@implementation DDLoginViewController

@synthesize textFieldEmail;
@synthesize textFieldPassword;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiDidAuthenticate:) name:DDAuthenticationControllerAuthenticateDidSucceesNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiDidNotAuthenticate:) name:DDAuthenticationControllerAuthenticateDidFailedNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Log In", nil);
    
    //add right button
    self.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Cancel", nil) target:self action:@selector(cancelTouched:)];

    //set focus
    [textFieldEmail becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [textFieldEmail release];
    [textFieldPassword release];
    [super dealloc];
}

#pragma mark -
#pragma mark IB

- (IBAction)loginTouched:(id)sender
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
    
    //authonticate with login and password
    [DDAuthenticationController authenticateWithEmail:self.textFieldEmail.text password:self.textFieldPassword.text delegate:self];
}

#pragma mark -
#pragma mark API

- (void)apiDidAuthenticate:(NSNotification*)notification
{
    //check for delegate
    if ([notification.userInfo objectForKey:DDAuthenticationControllerAuthenticateUserInfoDelegateKey] == self)
    {
        //hide hud
        [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:NO];
    
        //extract information about me
        [self.apiController getMe];
    }
}

- (void)apiDidNotAuthenticate:(NSNotification*)notification
{
    //check for delegate
    if ([notification.userInfo objectForKey:DDAuthenticationControllerAuthenticateUserInfoDelegateKey] == self)
    {
        //hide hude
        [self hideHud:YES];
        
        //try to get error
        NSError *error = [[notification userInfo] objectForKey:DDAuthenticationControllerAuthenticateDidFailedUserInfoErrorKey];
        if (error)
            [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
    }
}

- (void)getMeDidSucceed:(DDUser*)me
{
    //hide hude
    [self hideHud:NO];
    
    //start with user
    [(DDWelcomeViewController*)[self viewControllerForClass:[DDWelcomeViewController class]] startWithUser:me];
}

- (void)getMeDidFailedWithError:(NSError*)error
{
    //hide hude
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma mark other

- (void)cancelTouched:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
