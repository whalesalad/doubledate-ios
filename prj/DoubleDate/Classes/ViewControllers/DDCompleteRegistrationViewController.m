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
    self.user.email = textFieldEmail.text;
    self.user.password = textFieldPassword.text;
    
    //create user
    [controller_ createUser:self.user];
}

#pragma mark -
#pragma comment DDAPIControllerDelegate

- (void)createUserSucceed:(DDUser*)u
{
    //hide hud
    [self hideHud:YES];
    
    //copy password for further authentication
    u.password = self.user.password;
    
    //start with user
    [(DDWelcomeViewController*)[self viewControllerForClass:[DDWelcomeViewController class]] startWithUser:u];
}

- (void)createUserDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
