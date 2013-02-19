//
//  DDWelcomeViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDWelcomeViewController.h"
#import "DDFacebookController.h"
#import "MBProgressHUD.h"
#import <FacebookSDK/FacebookSDK.h>
#import <RestKit/RestKit.h>
#import "SBJson.h"
#import "DDBasicInfoViewController.h"
#import "DDTools.h"
#import "DDAuthenticationController.h"
#import "DDRequestsController.h"
#import "DDAPIController.h"
#import "DDLoginViewController.h"
#import "DDUser.h"
#import "DDMeViewController.h"
#import "DDWingsViewController.h"
#import "DDDoubleDatesViewController.h"
#import "DDTabBarBackgroundView.h"
#import "DDAppDelegate+NavigationMenu.h"
#import "DDEngagementsViewController.h"
#import "DDAppDelegate+Navigation.h"

#define kTagEmailActionSheet 1

@interface DDWelcomeViewController ()<UIActionSheetDelegate, DDAPIControllerDelegate>

- (void)joinWithEmail;
- (void)loginWithEmail;

- (void)registerWithUser:(DDUser*)user;

- (void)startWithUser:(DDUser*)user animated:(BOOL)animated;

@end

@implementation DDWelcomeViewController

@synthesize privacyShown;

@synthesize bottomView;
@synthesize privacyTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidLogin:) name:DDFacebookControllerSessionDidLoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidNotLogin:) name:DDFacebookControllerSessionDidNotLoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiDidAuthenticate:) name:DDAuthenticationControllerAuthenticateDidSucceesNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiDidNotAuthenticate:) name:DDAuthenticationControllerAuthenticateDidFailedNotification object:nil];
    }
    return self;
}

- (CGFloat)screenHeight
{
    if ([DDTools isiPhone5Device])
        return 548;
    return 460;
}

- (void)cutomizePrivacyTextView
{
    //set text
    NSString *title = NSLocalizedString(@"Your Provacy is Improtant!", nil);
    NSString *message = NSLocalizedString(@"We rely on Facebook to ensure That DoubleDate are genuine. We'll never post on your wall, or spam you friends. Promise!", nil);
    NSString *fullText = [NSString stringWithFormat:@"%@\n%@", title, message];
    
    //create attributed text
    NSMutableAttributedString *attributedText = [[[NSMutableAttributedString alloc] initWithString:fullText] autorelease];
    
    //cutomize notification
    [attributedText addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]
                           range:[fullText rangeOfString:title]];
    [attributedText addAttribute:NSForegroundColorAttributeName
                           value:[UIColor blackColor]
                           range:[fullText rangeOfString:title]];
    
    //cutomize date
    [attributedText addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:@"HelveticaNeue" size:13]
                           range:[fullText rangeOfString:message]];
    [attributedText addAttribute:NSForegroundColorAttributeName
                           value:[UIColor lightGrayColor]
                           range:[fullText rangeOfString:message]];
    
    // apply attributed text
    self.privacyTextView.attributedText = attributedText;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //as XIB set up with iPhone 5 resolution then apply change for usual iPhone
    if (![DDTools isiPhone5Device])
        self.bottomView.center = CGPointMake(self.bottomView.center.x, self.bottomView.center.y - (548-460));
    
    //measure height of unvisible bottom view
    if ([DDTools isiPhone5Device])
        bottomViewVisibleHeight_ = 548 - self.bottomView.frame.origin.y;
    else
        bottomViewVisibleHeight_ = 460 - self.bottomView.frame.origin.y;
    
    //update privacy text
    [self cutomizePrivacyTextView];
    
    //check the difference in size
    CGFloat dh = self.privacyTextView.contentSize.height - self.privacyTextView.frame.size.height;
    self.bottomView.frame = CGRectMake(self.bottomView.frame.origin.x, self.bottomView.frame.origin.y, self.bottomView.frame.size.width, self.bottomView.frame.size.height+dh);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)dealloc
{
    [bottomView release];
    [privacyTextView release];
    [super dealloc];
}

#pragma mark -
#pragma mark IB

- (IBAction)whyFacebookTouched:(id)sender
{
    self.privacyShown = !self.privacyShown;
}

- (IBAction)facebookTouched:(id)sender
{
    //start facebook
    [[DDFacebookController sharedController] login];
}

- (IBAction)emailTouched:(id)sender
{
    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Log In to DoubleDate", nil), NSLocalizedString(@"Sign Up with Email", nil), nil] autorelease];
    sheet.tag = kTagEmailActionSheet;
    [sheet showInView:self.view];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            if (actionSheet.tag == kTagEmailActionSheet)
                [self loginWithEmail];
            break;
        case 1:
            if (actionSheet.tag == kTagEmailActionSheet)
                [self joinWithEmail];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark other

- (void)setPrivacyShown:(BOOL)v
{
    //check the same value
    if (privacyShown != v)
    {
        //update value
        privacyShown = v;
        
        //animate
        [UIView animateWithDuration:0.5f animations:^{
            
            //animate bottom
            if (v)
                self.bottomView.frame = CGRectMake(self.bottomView.frame.origin.x, [self screenHeight] - self.bottomView.frame.size.height , self.bottomView.frame.size.width, self.bottomView.frame.size.height);
            else
                self.bottomView.frame = CGRectMake(self.bottomView.frame.origin.x, [self screenHeight] - bottomViewVisibleHeight_, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
        }];
    }
}

- (void)joinWithEmail
{
    [self registerWithUser:nil];
}

- (void)loginWithEmail
{
    [self.navigationController presentViewController:[[[UINavigationController alloc] initWithRootViewController:[[[DDLoginViewController alloc] init] autorelease]] autorelease] animated:YES completion:^{
    }];
}

- (void)registerWithUser:(DDUser*)user
{
    //go to next view controller
    DDBasicInfoViewController *viewController = [[[DDBasicInfoViewController alloc] init] autorelease];
    viewController.user = user;
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    [self.navigationController presentViewController:navigationController animated:YES completion:^{
    }];
}

#pragma mark -
#pragma mark Facebook

- (void)fbDidLogin:(NSNotification*)notification
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
    
    //try to authonticate with facebook
    [DDAuthenticationController authenticateWithFbToken:[DDFacebookController token] delegate:self];
}

- (void)fbDidNotLogin:(NSNotification*)notification
{
    //extract error
    NSError *error = [[notification userInfo] objectForKey:DDFacebookControllerSessionDidNotLoginUserInfoErrorKey];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
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
        //if user is not exist fetch new data
        NSNumber *responseCode = [[notification userInfo] objectForKey:DDAuthenticationControllerAuthenticateDidFailedUserInfoResponseCodeKey];
        NSString *code = [[notification userInfo] objectForKey:DDAuthenticationControllerAuthenticateDidFailedUserInfoCodeKey];
        if ([responseCode intValue] == 401 && [code isEqualToString:@"NO_FACEBOOK_USER"])
        {
            //show hud
            [self showHudWithText:NSLocalizedString(@"Fetching User", nil) animated:NO];
            
            //request information about the user
            [self.apiController requestFacebookUserForToken:[DDFacebookController token]];
        }
        else
        {
            //hide hude
            [self hideHud:YES];
            
            //try to get error
            NSError *error = [[notification userInfo] objectForKey:DDAuthenticationControllerAuthenticateDidFailedUserInfoErrorKey];
            if (error)
                [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
        }
    }
}

#pragma mark -
#pragma mark DDAPIControllerDelegate

- (void)getMeDidSucceed:(DDUser*)me
{
    //hide hude
    [self hideHud:YES];
    
    //start with user
    [self startWithUser:me animated:YES];
}

- (void)getMeDidFailedWithError:(NSError*)error
{
    //hide hude
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)requestFacebookUserSucceed:(DDUser*)user
{
    //hide hude
    [self hideHud:YES];
    
    //save access token
    user.facebookAccessToken = [DDFacebookController token];
    
    //register user
    [self registerWithUser:user];
}

- (void)requestFacebookDidFailedWithError:(NSError*)error
{
    //hide hude
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma mark other

- (void)startWithUser:(DDUser*)user animated:(BOOL)animated
{
    //dismiss all modal view controllers
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
    
    //save user to user defaults
    [DDAuthenticationController setCurrentUser:user];
    
    //login user
    [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] loginUser:user];
}

- (void)startWithUser:(DDUser *)user
{
    [self startWithUser:user animated:NO];
}

@end
