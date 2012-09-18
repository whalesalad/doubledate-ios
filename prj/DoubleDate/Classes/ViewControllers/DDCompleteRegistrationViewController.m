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

- (void)handleFinishForUser:(DDUser*)user;

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
    [createdUser_ release];
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
    
    //fill user data
    DDUser *newUser = [[user copy] autorelease];
    if ([textFieldEmail.text length])
        newUser.email = textFieldEmail.text;
    if ([textFieldPassword.text length])
        newUser.password = textFieldPassword.text;
    
    //remove not needed fields
    newUser.interests = nil;
    newUser.location = nil;
    newUser.photo = nil;
    
    //create user
    [controller_ createUser:newUser];
}

#pragma mark -
#pragma comment other

- (void)handleFinishForUser:(DDUser*)user
{
    //start with user
    [(DDWelcomeViewController*)[self viewControllerForClass:[DDWelcomeViewController class]] startWithUser:self.user];
}

#pragma mark -
#pragma comment DDAPIControllerDelegate

- (void)createUserSucceed:(DDUser*)u
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Updating", nil) animated:NO];
    
    //save created user
    [createdUser_ release];
    createdUser_ = [u retain];
    
    //authonticate user
    if (u.facebookId)
        [DDAuthenticationController authenticateWithFbToken:[DDFacebookController token] delegate:self];
    else
        [DDAuthenticationController authenticateWithEmail:textFieldEmail.text password:textFieldPassword.text delegate:self];
}

- (void)createUserDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)updateUserSucceed:(DDUser *)u
{
    //update object
    if (createdUser_ != u)
    {
        [createdUser_ release];
        createdUser_ = [u retain];
    }
    
    //check if we need to update the interests
    if (self.user.interests && !u.interests)
    {
        DDUser *newUser = [[[DDUser alloc] init] autorelease];
        newUser.interests = self.user.interests;
        [controller_ updateUser:newUser forId:[u.userId stringValue]];
    }
    else if (self.user.location && !u.location)
    {
        DDUser *newUser = [[[DDUser alloc] init] autorelease];
        newUser.location = self.user.location;
        [controller_ updateUser:newUser forId:[u.userId stringValue]];
    }
    else
    {
        //hide hud
        [self hideHud:YES];
        
        //finish
        [self handleFinishForUser:createdUser_];
    }
}

- (void)updateUserDidFailedWithError:(NSError *)error
{
    //hide hud
    [self hideHud:YES];
    
    //try to get error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
    
    //finish
    [self handleFinishForUser:createdUser_];
}

#pragma mark -
#pragma comment API

- (void)apiDidAuthenticate:(NSNotification*)notification
{
    //check for delegate
    if ([notification.userInfo objectForKey:DDAuthenticationControllerAuthenticateUserInfoDelegateKey] == self)
    {
        //show hud
        [self showHudWithText:NSLocalizedString(@"Updating", nil) animated:YES];

        //update created user
        [self updateUserSucceed:createdUser_];
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

@end
