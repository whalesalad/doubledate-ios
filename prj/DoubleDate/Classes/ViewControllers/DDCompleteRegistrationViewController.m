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
#import "DDImage.h"
#import "DDBarButtonItem.h"

@interface DDCompleteRegistrationViewController ()<DDAPIControllerDelegate>

- (void)handleFinishForUser:(DDUser*)user;

@end

@implementation DDCompleteRegistrationViewController

@synthesize user;
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
    self.navigationItem.title = NSLocalizedString(@"Almost Done!", nil);
    
    //add right button
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Finish", nil) target:self action:@selector(finishTouched:)];
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
    [super dealloc];
}

#pragma mark -
#pragma mark IB

- (IBAction)finishTouched:(id)sender
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
    
    //unset flags
    locationSent_ = NO;
    interestsSent_ = NO;
    posterSent_ = NO;
    
    //create user
    [self.apiController createUser:newUser];
}

#pragma mark -
#pragma mark other

- (void)handleFinishForUser:(DDUser*)u
{
    //start with user
    [(DDWelcomeViewController*)[self viewControllerForClass:[DDWelcomeViewController class]] startWithUser:u];
}

#pragma mark -
#pragma mark DDAPIControllerDelegate

- (void)createUserSucceed:(DDUser*)u
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Authorizing", nil) animated:NO];
    
    //save created user
    [createdUser_ release];
    createdUser_ = [u retain];
    
    //authonticate user
    if (u.facebookId)
        assert(0);
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

- (void)updateMeSucceed:(DDUser *)u
{
    //update object
    if (createdUser_ != u)
    {
        [createdUser_ release];
        createdUser_ = [u retain];
    }
    
    //check if we need to update the interests
    if (self.user.interests && !u.interests && !interestsSent_)
    {
        //save flag
        interestsSent_ = YES;
        
        //update user
        DDUser *newUser = [[[DDUser alloc] init] autorelease];
        newUser.interests = self.user.interests;
        [self.apiController updateMe:newUser];
    }
    //check if we need to update the location
    else if (self.user.location && !u.location && !locationSent_)
    {
        //save flag
        locationSent_ = YES;
        
        //update user
        DDUser *newUser = [[[DDUser alloc] init] autorelease];
        newUser.location = self.user.location;
        [self.apiController updateMe:newUser];
    }
    //check if we need to post the photo
    else if (self.user.photo.uploadImage && !posterSent_)
    {
        //save that poster sent
        posterSent_ = YES;
        
        //update user
        [self.apiController updatePhotoForMe:self.user.photo.uploadImage];
    }
    else
    {
        //hide hud
        [self hideHud:YES];
        
        //finish
        [self handleFinishForUser:createdUser_];
    }
}

- (void)updateMeDidFailedWithError:(NSError *)error
{
    //hide hud
    [self hideHud:YES];
    
    //try to get error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
    
    //finish
    [self handleFinishForUser:createdUser_];
}

- (void)updatePhotoForMeSucceed:(DDImage*)photo
{
    //copy data
    createdUser_.photo = photo;
    
    //update user
    [self updateMeSucceed:createdUser_];
}

- (void)updatePhotoForMeDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //try to get error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
    
    //finish
    [self handleFinishForUser:createdUser_];
}

#pragma mark -
#pragma mark API

- (void)apiDidAuthenticate:(NSNotification*)notification
{
    //check for delegate
    if ([notification.userInfo objectForKey:DDAuthenticationControllerAuthenticateUserInfoDelegateKey] == self)
    {
        //show hud
        [self showHudWithText:NSLocalizedString(@"Updating", nil) animated:NO];

        //update created user
        [self updateMeSucceed:createdUser_];
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
