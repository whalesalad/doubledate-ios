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
#import "JBKenBurnsView.h"

#define kTagEmailActionSheet 1

@interface DDWelcomeViewController ()<UIActionSheetDelegate, DDAPIControllerDelegate>

@property(nonatomic, retain) UIView *buildingOverlay;

- (void)joinWithEmail;
- (void)loginWithEmail;

- (void)registerWithUser:(DDUser*)user;

- (void)startWithUser:(DDUser*)user animated:(BOOL)animated;

- (void)startAnimation;
- (void)stopAnimation;

@end

@implementation DDWelcomeViewController

@synthesize buildingOverlay;

@synthesize privacyShown;

@synthesize bottomView;
@synthesize privacyTextView;
@synthesize logoImageView;
@synthesize fadeView;
@synthesize whyFacebookButton;
@synthesize animateView;

@synthesize labelGrabAFriend;
@synthesize buttonLoginWithFacebook;

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
    NSString *title = NSLocalizedString(@"Your Privacy is Important", nil);
    NSString *message = NSLocalizedString(@"We rely on Facebook to ensure That DoubleDaters are genuine. We'll never post on your wall, or spam your friends.", nil);
    NSString *fullText = [NSString stringWithFormat:@"%@\n%@", title, message];
    
    //create attributed text
    NSMutableAttributedString *attributedText = [[[NSMutableAttributedString alloc] initWithString:fullText] autorelease];
    
    //cutomize notification
    [attributedText addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:19]
                           range:[fullText rangeOfString:title]];
    [attributedText addAttribute:NSForegroundColorAttributeName
                           value:[UIColor whiteColor]
                           range:[fullText rangeOfString:title]];
    
    //cutomize date
    [attributedText addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:@"HelveticaNeue" size:17]
                           range:[fullText rangeOfString:message]];
    [attributedText addAttribute:NSForegroundColorAttributeName
                           value:[UIColor whiteColor]
                           range:[fullText rangeOfString:message]];
    
    // apply attributed text
    self.privacyTextView.attributedText = attributedText;
    
    //set text view alpha
    self.privacyTextView.alpha = 0;
}

- (void)startAnimation
{
    //stop animation at first
    [self stopAnimation];
    
    //add animation view
    KenBurnsView *animationView = [[[KenBurnsView alloc] initWithFrame:self.animateView.bounds] autorelease];
    animationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.animateView addSubview:animationView];
    
    //add images
    NSMutableArray *images = [NSMutableArray array];
    [images addObject:[UIImage imageNamed:@"bar.jpg"]];
    [images addObject:[UIImage imageNamed:@"beach.jpg"]];
    [images addObject:[UIImage imageNamed:@"boat.jpg"]];
    [images addObject:[UIImage imageNamed:@"bowling.jpg"]];
    [images addObject:[UIImage imageNamed:@"breakfast.jpg"]];
    [images addObject:[UIImage imageNamed:@"cycling.jpg"]];
    [images addObject:[UIImage imageNamed:@"fika.jpg"]];
    [images addObject:[UIImage imageNamed:@"golfing.jpg"]];
    [images addObject:[UIImage imageNamed:@"hiking.jpg"]];
    [images addObject:[UIImage imageNamed:@"horses.jpg"]];
    [images addObject:[UIImage imageNamed:@"jeep.jpg"]];
    [images addObject:[UIImage imageNamed:@"lounge.jpg"]];
    [images addObject:[UIImage imageNamed:@"lunch.jpg"]];
    [images addObject:[UIImage imageNamed:@"park.jpg"]];
    [images addObject:[UIImage imageNamed:@"skiing.jpg"]];
    [images addObject:[UIImage imageNamed:@"snorkel.jpg"]];
    [images addObject:[UIImage imageNamed:@"speedboat.jpg"]];
    [images addObject:[UIImage imageNamed:@"yoga.jpg"]];
    
    // Randomize the array...
    for (NSInteger i = images.count-1; i > 0; i--)
    {
        [images exchangeObjectAtIndex:i withObjectAtIndex:arc4random_uniform(i+1)];
    }
    
    //animate
    [animationView animateWithImages:images transitionDuration:8.0f loop:YES isLandscape:YES];
}

- (void)stopAnimation
{
    while ([[self.animateView subviews] count])
    {
        KenBurnsView *animationView = [[self.animateView subviews] lastObject];
        if ([animationView isKindOfClass:[KenBurnsView class]])
            animationView.isLoop = NO;
        [animationView removeFromSuperview];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //localize
    labelGrabAFriend.text = NSLocalizedString(@"GRAB A FRIEND • GO OUT • HAVE FUN", nil);
    [buttonLoginWithFacebook setTitle:NSLocalizedString(@"Login with Facebook", nil) forState:UIControlStateNormal];
    [whyFacebookButton setTitle:NSLocalizedString(@"WHY FACEBOOK?", nil) forState:UIControlStateNormal];
    
    //as XIB set up with iPhone 5 resolution then apply change for usual iPhone
    if (![DDTools isiPhone5Device])
        self.bottomView.center = CGPointMake(self.bottomView.center.x, self.bottomView.center.y - (548-460));
    
    //measure height of unvisible bottom view
    if ([DDTools isiPhone5Device])
        bottomViewVisibleHeight_ = 548 - self.bottomView.frame.origin.y;
    else
        bottomViewVisibleHeight_ = 460 - self.bottomView.frame.origin.y;
    
    if ([[UIScreen mainScreen] scale] == 1) {
        CGPoint fadeCenter = fadeView.center;
        CGPoint logoCenter = logoImageView.center;
        fadeCenter.y -= 40;
        logoCenter.y -= 40;
        fadeView.center = fadeCenter;
        logoImageView.center = logoCenter;
    }
    
    //update privacy text
    [self cutomizePrivacyTextView];
    
    //check the difference in size
    CGFloat dh = self.privacyTextView.contentSize.height - self.privacyTextView.frame.size.height;
    self.bottomView.frame = CGRectMake(self.bottomView.frame.origin.x, self.bottomView.frame.origin.y, self.bottomView.frame.size.width, self.bottomView.frame.size.height+dh);
    
    //save position of logo
    initialLogoPosition_ = self.logoImageView.center;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //hide navigation bar
    self.navigationController.navigationBarHidden = YES;
    
    //start animation
    [self startAnimation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //stop animation
    [self stopAnimation];
}

- (void)dealloc
{
    [bottomView release];
    [privacyTextView release];
    [logoImageView release];
    [fadeView release];
    [whyFacebookButton release];
    [animateView release];
    [labelGrabAFriend release];
    [buttonLoginWithFacebook release];
    [buildingOverlay release];
    [super dealloc];
}

#pragma mark -
#pragma mark IB

- (IBAction)whyFacebookOutTouched:(id)sender
{
    if (self.privacyShown)
        self.privacyShown = NO;
}

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
        [UIView animateWithDuration:0.3f animations:^{
            if (v) {
                logoImageView.center = CGPointMake(initialLogoPosition_.x, ([self screenHeight] - self.bottomView.frame.size.height) / 2);
                fadeView.alpha = 0;
                whyFacebookButton.alpha = 0;
                privacyTextView.alpha = 1;
                self.bottomView.frame = CGRectMake(self.bottomView.frame.origin.x, [self screenHeight] - self.bottomView.frame.size.height , self.bottomView.frame.size.width, self.bottomView.frame.size.height);
            } else {
                logoImageView.center = initialLogoPosition_;
                fadeView.alpha = 1;
                whyFacebookButton.alpha = 1;
                privacyTextView.alpha = 0;
                self.bottomView.frame = CGRectMake(self.bottomView.frame.origin.x, [self screenHeight] - bottomViewVisibleHeight_, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
            }
                
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

- (void)showBuildingOverlay
{
    //remove previous one
    [self.buildingOverlay removeFromSuperview];
    
    //save window
    UIWindow *window = [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] window];
    
    //create new one
    self.buildingOverlay = [[[UIView alloc] initWithFrame:window.bounds] autorelease];
    self.buildingOverlay.backgroundColor = [UIColor clearColor];
    self.buildingOverlay.alpha = 0;
    [window addSubview:self.buildingOverlay];
    
    //add overlay
    UIView *dim = [[[UIView alloc] initWithFrame:self.buildingOverlay.bounds] autorelease];
    dim.backgroundColor = [UIColor blackColor];
    dim.alpha = 0.8f;
    [self.buildingOverlay addSubview:dim];
    
    //add image
    UIImageView *imageView1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smiling-profile.png"]] autorelease];
    imageView1.center = CGPointMake(self.buildingOverlay.bounds.size.width/2, self.buildingOverlay.bounds.size.height/2);
    [self.buildingOverlay addSubview:imageView1];
    
    //add image
    UIImageView *imageView2 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile-spinner.png"]] autorelease];
    imageView2.center = CGPointMake(imageView1.center.x + imageView1.frame.size.width/2 - 8, imageView1.center.y - imageView1.frame.size.height/2 + 8);
    [self.buildingOverlay addSubview:imageView2];
    
    //animate rotation
    CGFloat duration = 10;
    CGFloat repeatCount = 1;
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * duration * repeatCount];
    rotationAnimation.duration = 10;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeatCount;
    [imageView2.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    //add label top
    UILabel *labelTop = [[[UILabel alloc] initWithFrame:CGRectMake(0, self.buildingOverlay.bounds.size.height/2 + 80, self.buildingOverlay.bounds.size.width, 32)] autorelease];
    labelTop.textAlignment = NSTextAlignmentCenter;
    labelTop.text = NSLocalizedString(@"We're building your profile", @"Building profile view, title text");
    labelTop.textColor = [UIColor whiteColor];
    labelTop.backgroundColor = [UIColor clearColor];
    labelTop.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:19];
    [self.buildingOverlay addSubview:labelTop];
    
    //add bottom top
    UILabel *labelBottom = [[[UILabel alloc] initWithFrame:CGRectMake(0, labelTop.frame.origin.y + labelTop.frame.size.height - 5, self.buildingOverlay.bounds.size.width, 32)] autorelease];
    labelBottom.textAlignment = NSTextAlignmentCenter;
    labelBottom.text = NSLocalizedString(@"It'll only take a moment", @"Building profile view, smaller detail text");
    labelBottom.textColor = [UIColor lightGrayColor];
    labelBottom.backgroundColor = [UIColor clearColor];
    labelBottom.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    [self.buildingOverlay addSubview:labelBottom];

    //animate
    [UIView animateWithDuration:0.2f animations:^{
        
        //show building overlay
        self.buildingOverlay.alpha = 1;
        
        //hide own views
        self.fadeView.alpha = 0;
        self.bottomView.alpha = 0;
        self.logoImageView.alpha = 0;
    }];
}

- (void)hideBuildingOverlay
{
    [UIView animateWithDuration:0.2f animations:^{
        
        //fade building
        self.buildingOverlay.alpha = 0;
        
        //show own views
        self.fadeView.alpha = 1;
        self.bottomView.alpha = 1;
        self.logoImageView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        //remove building overlay
        [self.buildingOverlay removeFromSuperview];
        self.buildingOverlay = nil;
        
        //finish fading
        self.fadeView.alpha = 1;
        self.bottomView.alpha = 1;
        self.logoImageView.alpha = 1;
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
        //show overlay
        if ([DDAuthenticationController isNewUser])
        {
            [self hideHud:YES];
            [self showBuildingOverlay];
        }
        else
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
    //set fake delay
    CGFloat delay = [DDAuthenticationController isNewUser]?10:0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
        
        //hide hud
        [self hideHud:YES];
        
        //hide building overlay
        [self hideBuildingOverlay];
        
        //start with user
        [self startWithUser:me animated:YES];
    });
}

- (void)getMeDidFailedWithError:(NSError*)error
{
    //hide hude
    [self hideHud:YES];
    
    //hide building overlay
    [self hideBuildingOverlay];
    
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
    
    //login user
    [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] loginUser:user];
}

- (void)startWithUser:(DDUser *)user
{
    [self startWithUser:user animated:NO];
}

@end
