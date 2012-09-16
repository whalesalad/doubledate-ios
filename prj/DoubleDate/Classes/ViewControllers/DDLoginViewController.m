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

@interface DDLoginViewController ()<DDAPIControllerDelegate>

@end

@implementation DDLoginViewController

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
    self.navigationItem.title = NSLocalizedString(@"Log In", nil);
    
    //add right button
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleDone target:self action:@selector(cancelTouched:)] autorelease];

    [textFieldEmail becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [textFieldEmail release], textFieldEmail = nil;
    [textFieldPassword release], textFieldPassword = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [textFieldEmail release];
    [textFieldPassword release];
    controller_.delegate = nil;
    [controller_ release];
    [super dealloc];
}

#pragma mark -
#pragma comment IB

- (IBAction)loginTouched:(id)sender
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
    
    //authonticate with login and password
    [DDAuthenticationController authenticateWithEmail:self.textFieldEmail.text password:self.textFieldPassword.text delegate:self];
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
#pragma comment other

- (void)cancelTouched:(id)sender
{
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

@end
