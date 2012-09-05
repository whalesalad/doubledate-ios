//
//  DDWelcomeViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDWelcomeViewController.h"
#import "MBProgressHUD.h"
#import <FacebookSDK/FacebookSDK.h>

@interface DDWelcomeViewController ()<UIActionSheetDelegate>

- (void)joinWithFacebook;
- (void)joinWithEmail;

@end

@implementation DDWelcomeViewController

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark IB

- (IBAction)signupTouched:(id)sender
{
    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Join with Facebook", nil), NSLocalizedString(@"Join with Email", nil), nil] autorelease];
    [sheet showInView:self.view];
}

- (IBAction)loginTouched:(id)sender
{
    
}


#pragma mark -
#pragma mark UIActionSheetDelegate

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
#pragma mark other

- (void)joinWithFacebook
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Logging in", nil) animated:YES];
}

- (void)joinWithEmail
{
    
}

#pragma mark -
#pragma mark Facebook

@end
