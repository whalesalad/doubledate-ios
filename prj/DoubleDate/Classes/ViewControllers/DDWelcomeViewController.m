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

#define kTagEmailActionSheet 1

@interface DDWelcomeViewController ()<UIActionSheetDelegate, DDAPIControllerDelegate>

- (void)joinWithEmail;
- (void)loginWithEmail;

- (void)registerWithUser:(DDUser*)user;

- (void)startWithUser:(DDUser*)user animated:(BOOL)animated;

@end

@implementation DDWelcomeViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [super dealloc];
}

#pragma mark -
#pragma mark IB

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
    
    //check user
    if (user)
    {
        //set notifications view controller
        DDViewController *notificationsViewController = [[[DDViewController alloc] init] autorelease];
        notificationsViewController.hidesBottomBarWhenPushed = YES;
        notificationsViewController.shouldShowNavigationMenu = YES;
        
        //set me view controller
        DDMeViewController *meViewController = [[[DDMeViewController alloc] init] autorelease];
        meViewController.user = user;
        meViewController.hidesBottomBarWhenPushed = YES;
        meViewController.shouldShowNavigationMenu = YES;
        
        //set wingman view controller
        DDWingsViewController *wingsViewController = [[[DDWingsViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        wingsViewController.user = user;
        wingsViewController.hidesBottomBarWhenPushed = YES;
        wingsViewController.shouldShowNavigationMenu = YES;
        
        //set browse view controller
        DDDoubleDatesViewController *browseViewController = [[[DDDoubleDatesViewController alloc] init] autorelease];
        browseViewController.mode = DDDoubleDatesViewControllerModeAll;
        browseViewController.user = user;
        browseViewController.hidesBottomBarWhenPushed = YES;
        browseViewController.shouldShowNavigationMenu = YES;
        
        //add messages view controller
        DDEngagementsViewController *messagesViewController = [[[DDEngagementsViewController alloc] init] autorelease];
        messagesViewController.weakParentViewController = messagesViewController;
        messagesViewController.hidesBottomBarWhenPushed = YES;
        messagesViewController.shouldShowNavigationMenu = YES;
        
        //create tab bar controller
        UITabBarController *tabBarController = [[[UITabBarController alloc] init] autorelease];
        NSMutableArray *viewControllers = [NSMutableArray array];
        [viewControllers addObject:[[[UINavigationController alloc] initWithRootViewController:notificationsViewController] autorelease]];
        [viewControllers addObject:[[[UINavigationController alloc] initWithRootViewController:meViewController] autorelease]];
        [viewControllers addObject:[[[UINavigationController alloc] initWithRootViewController:wingsViewController] autorelease]];
        [viewControllers addObject:[[[UINavigationController alloc] initWithRootViewController:browseViewController] autorelease]];
        [viewControllers addObject:[[[UINavigationController alloc] initWithRootViewController:messagesViewController] autorelease]];
        tabBarController.viewControllers = viewControllers;
        
        //check each view controller
        for (UINavigationController *nc in viewControllers)
        {
            if ([nc isKindOfClass:[UINavigationController class]])
                nc.delegate = (DDAppDelegate*)[[UIApplication sharedApplication] delegate];
        }
        
        //default is me tab
        tabBarController.selectedIndex = 1;
        
        //go to next view controller
        [self.navigationController pushViewController:tabBarController animated:animated];
    }
}

- (void)startWithUser:(DDUser *)user
{
    [self startWithUser:user animated:NO];
}

@end
