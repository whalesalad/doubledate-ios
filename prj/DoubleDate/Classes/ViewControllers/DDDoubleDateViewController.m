//
//  DDDoubleDateViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 11/16/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDDoubleDateViewController.h"
#import "DDDoubleDate.h"
#import "DDLocationTableViewCell.h"
#import "DDCreateDoubleDateViewController.h"
#import "DDImageView.h"
#import "DDImage.h"
#import "DDShortUser.h"
#import "DDEngagement.h"
#import "DDUser.h"
#import "DDPlacemark.h"
#import "DDSendEngagementViewController.h"
#import "DDButton.h"
#import "DDPhotoView.h"
#import "DDAuthenticationController.h"
#import "DDTools.h"
#import "DDEngagementsViewController.h"
#import "DDUserBubble.h"
#import "DDSegmentedControl.h"
#import "DDChatViewController.h"
#import "DDObjectsController.h"
#import "DDAppDelegate+UserBubble.h"
#import "DDBarButtonItem.h"
#import "DDUserView.h"
#import "UIImage+DD.h"
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>

@interface DDDoubleDateViewController ()<DDSendEngagementViewControllerDelegate, UIScrollViewDelegate>

- (void)loadDataForUser:(DDShortUser*)shortUser;
- (void)presentLeftUserPopover;
- (void)presentRightUserPopover;
- (void)switchToNeededMode;

@property(nonatomic, retain) DDUser *user;
@property(nonatomic, retain) DDUser *wing;

@property(nonatomic, retain) UIView *popover;

@end

@implementation DDDoubleDateViewController

@synthesize user;
@synthesize wing;

@synthesize popover;

@synthesize doubleDate;

@synthesize scrollView;
@synthesize bottomView;

@synthesize buttonInterested;

@synthesize scrollTopView;
@synthesize scrollCenterView;
@synthesize scrollBottomView;

@synthesize labelLocationMain;
@synthesize labelLocationDetailed;

@synthesize textView;

@synthesize labelInterested;

@synthesize sentView;
@synthesize sentViewAnimation;
@synthesize labelMessageSent;

@synthesize leftUserView;
@synthesize rightUserView;

@synthesize mapView;

- (id)initWithDoubleDate:(DDDoubleDate*)doubleDate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
    }
    return self;
}

- (void)updateSentMessage
{
    if (self.doubleDate.engagement)
    {
        //set text
        NSString *text = [NSString stringWithFormat:NSLocalizedString(@"%@ sent a message to %@ & %@ %@ ago.", @"Doubledate page - floating view that message already sent"), self.doubleDate.engagement.displayName, self.doubleDate.user.firstName, self.doubleDate.wing.firstName, self.doubleDate.engagement.createdAtAgo];
        
        //apply label text
        labelMessageSent.text = text;
        
        //update label size according to content
        CGSize newLabelSize = [text sizeWithFont:labelMessageSent.font constrainedToSize:CGSizeMake(labelMessageSent.frame.size.width, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        
        //update the number of label lines
        labelMessageSent.numberOfLines = newLabelSize.height / labelMessageSent.font.pointSize;
        
        //hide if not needed
        self.sentView.hidden = NO;
        
        //update alfa
        self.sentView.alpha = 0;
    }
    else
        self.sentView.hidden = YES;
}

- (void)animateWarningView
{
    //check if warning is not hidden
    if (!self.sentView.hidden)
    {
        //don't show out of the bouns
        self.sentView.clipsToBounds = YES;
        
        //save the frame
        CGRect warningFrame = self.sentViewAnimation.frame;
        
        //change the height to 0
        self.sentViewAnimation.frame = CGRectMake(0, warningFrame.size.height, warningFrame.size.width, warningFrame.size.height);
        
        //animate
        [UIView animateWithDuration:0.2f animations:^{
            self.sentViewAnimation.frame = warningFrame;
            self.sentView.alpha = 1;
        }];
    }
}

- (void)hideWarningView
{
    //check if warning is not hidden
    if (!self.sentView.hidden)
    {
        //disable user interaction
        self.sentView.userInteractionEnabled = NO;
        
        //save the frame
        CGRect warningFrame = self.sentViewAnimation.frame;
        
        //animate
        [UIView animateWithDuration:0.2f animations:^{
            self.sentViewAnimation.frame = CGRectMake(0, warningFrame.size.height, warningFrame.size.width, warningFrame.size.height);
            self.sentView.alpha = 0;
        } completion:^(BOOL finished) {
            self.sentView.hidden = YES;
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // style scrolltopview (user photo container view)
    [DDTools styleDualUserView:self.scrollTopView];
    
    //localize
    labelInterested.text = NSLocalizedString(@"Interested in this DoubleDate?", nil);
    
    self.navigationItem.leftBarButtonItem = [DDBarButtonItem backBarButtonItemWithTitle:NSLocalizedString(@"Back", nil) target:self action:@selector(backTouched:)];
    
    //set navigation item
    self.navigationItem.title = NSLocalizedString(@"Details", nil);
        
    //customize intereseted button
    [self.buttonInterested setTitle:NSLocalizedString(@"Send a Message", nil) forState:UIControlStateNormal];
    [self.buttonInterested setBackgroundImage:[[self.buttonInterested backgroundImageForState:UIControlStateNormal] resizableImage] forState:UIControlStateNormal];
    
    //fill data
    self.labelLocationMain.text = [DDLocationTableViewCell mainTitleForLocation:self.doubleDate.location];
    self.labelLocationDetailed.text = [DDLocationTableViewCell detailedTitleForLocation:self.doubleDate.location];
    
    //set text
    self.textView.text = [self.doubleDate details];
    
    // Adjust size of textview.
    CGRect textFrame = self.textView.frame;
    textFrame.size.height = self.textView.contentSize.height + self.textView.contentInset.top + self.textView.contentInset.bottom;
    self.textView.frame = textFrame;
    
    // customize location view
    [self customizeLocationView];
    
    //customize user views
    DDUserView *userView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DDUserView class]) owner:self options:nil] objectAtIndex:0];
    userView.frame = self.leftUserView.bounds;
    userView.shortUser = self.doubleDate.user;
    [self.leftUserView addSubview:userView];
    DDUserView *wingView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DDUserView class]) owner:self options:nil] objectAtIndex:0];
    wingView.frame = self.rightUserView.bounds;
    wingView.shortUser = self.doubleDate.wing;
    [self.rightUserView addSubview:wingView];
    
    //request information
    if (!self.user && self.doubleDate.user)
    {
        DDUser *requestUser = [[[DDUser alloc] init] autorelease];
        requestUser.userId = self.doubleDate.user.identifier;
        [self.apiController getUser:requestUser];
    }
    if (!self.wing && self.doubleDate.wing)
    {
        DDUser *requestUser = [[[DDUser alloc] init] autorelease];
        requestUser.userId = self.doubleDate.wing.identifier;
        [self.apiController getUser:requestUser];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //switch to needed mode
    [self switchToNeededMode];
    
    //update sent message view
    [self updateSentMessage];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //animate warning view
    if (!messageSentAnimated_)
    {
        if (self.doubleDate.engagement)
        {
            if (!messageSent_)
                [self animateWarningView];
            else
                [self performSelector:@selector(animateWarningView) withObject:nil afterDelay:2];
            messageSentAnimated_ = YES;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [doubleDate release];
    [popover release];
    [scrollView release];
    [bottomView release];
    [buttonInterested release];
    [scrollTopView release];
    [scrollCenterView release];
    [scrollBottomView release];
    [labelLocationMain release];
    [labelLocationDetailed release];
    [textView release];
    [labelInterested release];
    [sentView release];
    [sentViewAnimation release];
    [labelMessageSent release];
    [leftUserView release];
    [rightUserView release];
    [mapView release];
    [_labelLocationDistance release];
    [super dealloc];
}

#pragma mark -
#pragma mark IB

- (IBAction)leftUserTouched:(DDPhotoView*)sender
{
    //present user
    [self presentLeftUserPopover];
}

- (IBAction)rightUserTouched:(DDPhotoView*)sender
{
    //present user
    [self presentRightUserPopover];
}

- (IBAction)interestedTouched:(id)sender
{
    DDSendEngagementViewController *vc = [[[DDSendEngagementViewController alloc] init] autorelease];
    vc.doubleDate = self.doubleDate;
    vc.delegate = self;
    [self.navigationController presentViewController:[[[UINavigationController alloc] initWithRootViewController:vc] autorelease] animated:YES completion:^{
    }];
}

- (IBAction)closeWarningTouched:(id)sender
{
    [self hideWarningView];
}

#pragma mark -
#pragma mark other

- (void)customizeLocationView
{
    CGRect locationFrame = self.scrollBottomView.frame;
    locationFrame.origin.y = self.textView.frame.origin.y + self.textView.frame.size.height + 20;
    self.scrollBottomView.frame = locationFrame;
    self.scrollBottomView.layer.cornerRadius = 5.0f;
    
    // Reposition the main label if there is no detailed label.
    if (self.doubleDate.location.isCity) {
        self.labelLocationMain.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        CGPoint locationMainCenter = self.labelLocationMain.center;
        locationMainCenter.y = self.labelLocationDistance.center.y;
        self.labelLocationMain.center = locationMainCenter;
        self.labelLocationDetailed.hidden = YES;
    }
    
    // distance
    self.labelLocationDistance.backgroundColor = [UIColor clearColor];
    self.labelLocationDistance.textColor = [UIColor lightGrayColor];
    self.labelLocationDistance.text = [NSString stringWithFormat:@"%d km", [self.doubleDate.location.distance intValue]];
    
    // Set region of map view
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.doubleDate.location.coordinate, 500, 500);
    [self.mapView setRegion:region animated:YES];
    
    // Add a point for the location
    MKPointAnnotation *locationPoint = [[MKPointAnnotation alloc] init];
    locationPoint.coordinate = self.doubleDate.location.coordinate;
    locationPoint.title = self.labelLocationMain.text;
    
    [self.mapView addAnnotation:locationPoint];
    
}

- (void)switchToNeededMode
{
    //save visibility
    BOOL bottomVisible = (!messageSent_ && [self.doubleDate.relationship isEqualToString:DDDoubleDateRelationshipOpen]);
    
    //change visibility
    self.bottomView.hidden = !bottomVisible;
//    self.bottomView.hidden = FALSE;
    
    //change frame
//    CGFloat yb = bottomVisible ? self.bottomView.frame.origin.y + 4 : self.bottomView.frame.origin.y + self.bottomView.frame.size.height - 8;

//    self.scrollView.frame = CGRectMake(0, 0, 320, yb);
    
    //this is a difference from xib
    //XXX customization of text view from xib
//    CGFloat diffBetweenTextViewAndCenterView = 142 - 86;
//    CGFloat neededHeightOfTextField = [self.textView sizeThatFits:self.textView.contentSize].height;
//    CGFloat neededHeightOfCenterView = MAX(neededHeightOfTextField + diffBetweenTextViewAndCenterView, 142);

    //change center view frame
//    self.scrollCenterView.frame = CGRectMake(0, self.scrollTopView.frame.origin.y+self.scrollTopView.frame.size.height, 320, neededHeightOfCenterView);
    
    //change content size
//    self.scrollView.contentSize = CGSizeMake(320, self.scrollTopView.frame.size.height + self.scrollCenterView.frame.size.height + self.scrollBottomView.frame.size.height);
    
    //set bottom view frame
//    self.scrollBottomView.frame = CGRectMake(self.scrollBottomView.frame.origin.x, self.scrollCenterView.frame.origin.y+scrollCenterView.frame.size.height, self.scrollBottomView.frame.size.width, self.scrollBottomView.frame.size.height);
}

- (void)presentPopoverWithUser:(DDUser*)u inView:(UIView*)popoverView
{
    //check user
    assert(self.user == u || self.wing == u);
    
    //present user bubble
    NSMutableArray *users = [NSMutableArray array];
    if (self.user)
        [users addObject:self.user];
    if (self.wing)
        [users addObject:self.wing];
    [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] presentUserBubbleForUser:u fromUsers:users];
}

- (void)loadDataForUser:(DDShortUser*)shortUser
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Loading...", nil) animated:YES];
    
    //request user
    DDUser *requestUser = [[[DDUser alloc] init] autorelease];
    requestUser.userId = [NSString stringWithFormat:@"%d", [shortUser.identifier intValue]];
    [self.apiController getUser:requestUser];
}

- (void)presentLeftUserPopover
{
    //load data
    if (self.user)
        [self getUserDidSucceed:self.user];
    else
        [self loadDataForUser:self.doubleDate.user];
}

- (void)presentRightUserPopover
{
    //load data
    if (self.wing)
        [self getUserDidSucceed:self.wing];
    else
        [self loadDataForUser:self.doubleDate.wing];
}

#pragma mark -
#pragma comment DDAPIControllerDelegate

- (void)getUserDidSucceed:(DDUser*)u
{
    //if hud exist then we load info about user
    BOOL needPresentPopover = [self isHudExist];
    
    //hide hud
    [self hideHud:YES];
    
    //save user
    if ([u.userId intValue] == [self.doubleDate.user.identifier intValue])
    {
        needPresentPopover = needPresentPopover || (self.user != nil);
        self.user = u;
    }
    else if ([u.userId intValue] == [self.doubleDate.wing.identifier intValue])
    {
        needPresentPopover = needPresentPopover || (self.wing != nil);
        self.wing = u;
    }
    
    //present needed view controller
    if (needPresentPopover)
    {
#pragma warning left/right arrow offsets
        if ([u.userId intValue] == [self.doubleDate.user.identifier intValue])
            [self presentPopoverWithUser:u inView:self.leftUserView];
        else
            [self presentPopoverWithUser:u inView:self.rightUserView];
    }
}

- (void)getUserDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma mark DDSendEngagementViewControllerDelegate

- (void)sendEngagementViewControllerDidCancel
{
    //dismiss
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)sendEngagementViewControllerDidCreatedEngagement:(DDEngagement*)engagement
{
    //save that we sent a message
    messageSent_ = YES;
    
    //add engagment into the double date
    self.doubleDate.engagement = engagement;
    
    //add overlay
    UIView *overlay = [[[UIView alloc] initWithFrame:self.navigationController.view.bounds] autorelease];
    overlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9f];
    [self.navigationController.view addSubview:overlay];
    
    //add image
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sent-engagement-plane.png"]] autorelease];
    imageView.center = CGPointMake(overlay.bounds.size.width/2, overlay.bounds.size.height/2-27);
    [overlay addSubview:imageView];
    
    //add label
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 60)] autorelease];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:19];
    label.numberOfLines = 2;
    NSString *format = NSLocalizedString(@"Your message has been sent\nto %@ & %@!", nil);
    label.text = [NSString stringWithFormat:format, self.doubleDate.user.firstName, self.doubleDate.wing.firstName];
    label.center = CGPointMake(overlay.bounds.size.width/2, overlay.bounds.size.height/2+47);
    [overlay addSubview:label];
    
    //hide after a moment
    [UIView animateWithDuration:0.4f delay:2 options:UIViewAnimationOptionLayoutSubviews animations:^{
        overlay.alpha = 0;
    } completion:^(BOOL finished) {
        [overlay removeFromSuperview];
    }];
    
    //dismiss
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
    
    //update doubledate in background
    [self.apiController getDoubleDate:self.doubleDate];
}

@end
