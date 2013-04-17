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

@synthesize imageViewLeft;
@synthesize imageViewRight;

@synthesize buttonInterested;

@synthesize scrollTopView;
@synthesize scrollCenterView;
@synthesize scrollBottomView;

@synthesize labelLocationMain;
@synthesize labelLocationDetailed;
@synthesize labelDayTime;
@synthesize labelDayTimeDetailed;

@synthesize labelTitle;
@synthesize textView;

@synthesize labelLeftUser;
@synthesize labelRightUser;

@synthesize imageViewLeftUserGender;
@synthesize imageViewRightUserGender;

@synthesize leftView;
@synthesize rightView;

@synthesize labelInterested;

@synthesize sentView;
@synthesize sentViewAnimation;
@synthesize labelMessageSent;

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
    
    //localize
    labelInterested.text = NSLocalizedString(@"Interested in this DoubleDate?", nil);
    [buttonInterested setTitle:NSLocalizedString(@"Send a Message", nil) forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = [DDBarButtonItem backBarButtonItemWithTitle:NSLocalizedString(@"Back", nil) target:self action:@selector(backTouched:)];
    
    //set navigation item
    self.navigationItem.title = NSLocalizedString(@"Details", nil);
    
    //set title label
    self.labelTitle.text = [self.doubleDate title];
    
    //customize text
    DD_F_TEXT(self.textView);
    
    //customize intereseted button
    [self.buttonInterested setTitle:NSLocalizedString(@"Send a Message", nil) forState:UIControlStateNormal];
    [self.buttonInterested setBackgroundImage:[DDTools resizableImageFromImage:[self.buttonInterested backgroundImageForState:UIControlStateNormal]] forState:UIControlStateNormal];
    
    //fill data
    self.labelLocationMain.text = [DDLocationTableViewCell mainTitleForLocation:self.doubleDate.location];
    self.labelLocationDetailed.text = [DDLocationTableViewCell detailedTitleForLocation:self.doubleDate.location];
    self.labelDayTime.text = [DDCreateDoubleDateViewController titleForDDDay:self.doubleDate.dayPref ddTime:self.doubleDate.timePref];
    
    //set text
    self.textView.text = [self.doubleDate details];

    //customize photo views
    if (self.doubleDate.user.photo.smallUrl)
        [self.imageViewLeft reloadFromUrl:[NSURL URLWithString:self.doubleDate.user.photo.smallUrl]];
    if (self.doubleDate.wing.photo.smallUrl)
        [self.imageViewRight reloadFromUrl:[NSURL URLWithString:self.doubleDate.wing.photo.smallUrl]];

    //set name
    self.labelLeftUser.text = [self.doubleDate.user.firstName uppercaseString];
    [self.labelLeftUser sizeToFit];
    self.labelLeftUser.center = CGPointMake(80-8, self.labelLeftUser.center.y);
    self.labelRightUser.text = [self.doubleDate.wing.firstName uppercaseString];
    [self.labelRightUser sizeToFit];
    self.labelRightUser.center = CGPointMake(240-8, self.labelRightUser.center.y);
    
    //set gender
    if ([[self.doubleDate.user gender] isEqualToString:DDUserGenderFemale])
        self.imageViewLeftUserGender.image = [UIImage imageNamed:@"icon-gender-female.png"];
    else
        self.imageViewLeftUserGender.image = [UIImage imageNamed:@"icon-gender-male.png"];
    imageViewLeftUserGender.frame = CGRectMake(labelLeftUser.frame.origin.x+labelLeftUser.frame.size.width+4, labelLeftUser.center.y-imageViewLeftUserGender.image.size.height/2, imageViewLeftUserGender.image.size.width, imageViewLeftUserGender.image.size.height);
    if ([[self.doubleDate.wing gender] isEqualToString:DDUserGenderFemale])
        self.imageViewRightUserGender.image = [UIImage imageNamed:@"icon-gender-female.png"];
    else
        self.imageViewRightUserGender.image = [UIImage imageNamed:@"icon-gender-male.png"];
    imageViewRightUserGender.frame = CGRectMake(labelRightUser.frame.origin.x+labelRightUser.frame.size.width+4, labelLeftUser.center.y-imageViewRightUserGender.image.size.height/2, imageViewRightUserGender.image.size.width, imageViewRightUserGender.image.size.height);
    
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
    [imageViewLeft release];
    [imageViewRight release];
    [buttonInterested release];
    [scrollTopView release];
    [scrollCenterView release];
    [scrollBottomView release];
    [labelLocationMain release];
    [labelLocationDetailed release];
    [labelDayTime release];
    [labelDayTimeDetailed release];
    [labelTitle release];
    [textView release];
    [labelLeftUser release];
    [labelRightUser release];
    [imageViewLeftUserGender release];
    [imageViewRightUserGender release];
    [leftView release];
    [rightView release];
    [labelInterested release];
    [sentView release];
    [sentViewAnimation release];
    [labelMessageSent release];
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

- (void)switchToNeededMode
{
    //save visibility
    BOOL bottomVisible = (!messageSent_ && [self.doubleDate.relationship isEqualToString:DDDoubleDateRelationshipOpen]);
    
    //change visibility
    self.bottomView.hidden = !bottomVisible;
    
    //change frame
    CGFloat yb = bottomVisible ? self.bottomView.frame.origin.y + 4 : self.bottomView.frame.origin.y + self.bottomView.frame.size.height - 8;

    self.scrollView.frame = CGRectMake(0, 0, 320, yb);
    
    //this is a difference from xib
    //XXX customization of text view from xib
    CGFloat diffBetweenTextViewAndCenterView = 142 - 86;
    CGFloat neededHeightOfTextField = [self.textView sizeThatFits:self.textView.contentSize].height;
    CGFloat neededHeightOfCenterView = MAX(neededHeightOfTextField + diffBetweenTextViewAndCenterView, 142);

    //change center view frame
    self.scrollCenterView.frame = CGRectMake(0, self.scrollTopView.frame.origin.y+self.scrollTopView.frame.size.height, 320, neededHeightOfCenterView);
    
    //change content size
    self.scrollView.contentSize = CGSizeMake(320, self.scrollTopView.frame.size.height + self.scrollCenterView.frame.size.height + self.scrollBottomView.frame.size.height);
    
    //set bottom view frame
    self.scrollBottomView.frame = CGRectMake(self.scrollBottomView.frame.origin.x, self.scrollCenterView.frame.origin.y+scrollCenterView.frame.size.height, self.scrollBottomView.frame.size.width, self.scrollBottomView.frame.size.height);
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
            [self presentPopoverWithUser:u inView:self.imageViewLeft];
        else
            [self presentPopoverWithUser:u inView:self.imageViewRight];
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
