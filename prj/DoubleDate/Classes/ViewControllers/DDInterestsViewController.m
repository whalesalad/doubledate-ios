//
//  DDInterestsViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/10/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDInterestsViewController.h"
#import "DDUser.h"
#import "DDAPIController.h"
#import "DDCompleteRegistrationViewController.h"
#import "JSTokenButton.h"
#import "DDInterest.h"
#import "DDAuthenticationController.h"
#import "DDFacebookController.h"
#import "DDWelcomeViewController.h"
#import "DDImage.h"
#import "DDBarButtonItem.h"

@interface DDInterestsViewController ()<DDAPIControllerDelegate>

@end

@implementation DDInterestsViewController

@synthesize user;
@synthesize tokenFieldViewInterests;

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check if we need to make a request
    if (!interestsRequested_)
    {
        //save that interests already requested
        interestsRequested_ = YES;
        
        //show hud
        [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
        
        //search for placemarks
        [self.apiController requestAvailableInterests];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Your Interests", nil);
    
    //add right button
    if (!user.facebookId)
        self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Next", nil) target:self action:@selector(nextTouched:)];
    else
        self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Finish", nil) target:self action:@selector(finishTouched:)];
    
    //add token title
    [tokenFieldViewInterests.tokenField setPromptText:NSLocalizedString(@"Interests:", nil)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [tokenFieldViewInterests release], tokenFieldViewInterests = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [user release];
    [tokenFieldViewInterests release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (void)nextTouched:(id)sender
{
    //add interests
    NSMutableArray *interests = [NSMutableArray array];
    for (NSString *title in self.tokenFieldViewInterests.tokenTitles)
    {
        DDInterest *interest = [[[DDInterest alloc] init] autorelease];
        interest.name = title;
        [interests addObject:interest];
    }
    
    //fill user data
    DDUser *newUser = [[user copy] autorelease];
    if ([interests count])
        newUser.interests = interests;
    else
        newUser.interests = nil;
    
    //go to next
    DDCompleteRegistrationViewController *viewController = [[[DDCompleteRegistrationViewController alloc] init] autorelease];
    viewController.user = newUser;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)finishTouched:(id)sender
{
    //fill user data
    DDUser *newUser = [[user copy] autorelease];
    
    //remove not needed fields
    newUser.interests = nil;
    newUser.location = nil;
    newUser.photo = nil;
    
    //unset flags
    locationSent_ = NO;
    interestsSent_ = NO;
    posterSent_ = NO;
    
    //show hud
    [self showHudWithText:NSLocalizedString(@"Creating", nil) animated:YES];
    
    //create user
    [self.apiController createUser:newUser];
}

#pragma mark -
#pragma mark -

- (void)requestAvailableInterestsSucceed:(NSArray*)interests
{
    //hide hud
    [self hideHud:YES];
    
    //copy interests
    NSMutableArray *res = [NSMutableArray array];
    for (DDInterest *interest in interests)
        [res addObject:interest.name];
    
    //save interest
    self.tokenFieldViewInterests.sourceArray = res;
}

- (void)requestAvailableInterestsDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
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
        [DDAuthenticationController authenticateWithFbToken:[DDFacebookController token] delegate:self];
    else
        assert(0);
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
    //add interests
    NSMutableArray *interests = [NSMutableArray array];
    for (NSString *title in self.tokenFieldViewInterests.tokenTitles)
    {
        DDInterest *interest = [[[DDInterest alloc] init] autorelease];
        interest.name = title;
        [interests addObject:interest];
    }
    
    //update object
    if (createdUser_ != u)
    {
        [createdUser_ release];
        createdUser_ = [u retain];
    }
    
    //check if we need to update the interests
    if ([interests count] && !u.interests && !interestsSent_)
    {
        //save flag
        interestsSent_ = YES;
        
        //update user
        DDUser *newUser = [[[DDUser alloc] init] autorelease];
        newUser.interests = interests;
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
