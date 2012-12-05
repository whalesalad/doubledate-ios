//
//  DDBioViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/10/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDBioViewController.h"
#import "DDUser.h"
#import "DDInterestsViewController.h"
#import "DDBarButtonItem.h"

@interface DDBioViewController ()

@end

@implementation DDBioViewController

@synthesize user;
@synthesize textViewBio;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Your Bio", nil);
    
    //add right button
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Next", nil) target:self action:@selector(nextTouched:)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [user release];
    [textViewBio release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (void)nextTouched:(id)sender
{
    //fill user data
    DDUser *newUser = [[user copy] autorelease];
    newUser.bio = self.textViewBio.text;
    
    //go next
    DDInterestsViewController *viewController = [[[DDInterestsViewController alloc] init] autorelease];
    viewController.user = newUser;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
