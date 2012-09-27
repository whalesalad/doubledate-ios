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
        controller_ = [[DDAPIController alloc] init];
        controller_.delegate = self;
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
        [controller_ requestAvailableInterests];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Your Interests", nil);
    
    //add right button
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(nextTouched:)] autorelease];
    
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
    controller_.delegate = nil;
    [controller_ release];
    [super dealloc];
}

#pragma mark -
#pragma comment other

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

#pragma mark -
#pragma comment -

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

@end
