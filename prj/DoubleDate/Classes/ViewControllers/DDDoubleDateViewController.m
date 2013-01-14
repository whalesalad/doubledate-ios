//
//  DDDoubleDateViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 11/16/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDateViewController.h"
#import "DDDoubleDate.h"
#import "DDLocationTableViewCell.h"
#import "DDCreateDoubleDateViewController.h"
#import "DDImageView.h"
#import "DDImage.h"
#import "DDShortUser.h"
#import "DDShortUser.h"
#import "DDUser.h"
#import "DDSendEngagementViewController.h"
#import "DDButton.h"
#import "DDPhotoView.h"
#import "DDAuthenticationController.h"
#import "DDTools.h"
#import "DDEngagementsViewController.h"
#import "DDUserBubble.h"

typedef enum
{
    DDDoubleDateViewControllerModeNone = 1<<0,
    DDDoubleDateViewControllerModeIncoming = 1<<1,
    DDDoubleDateViewControllerModeChat = 1<<2
} DDDoubleDateViewControllerMode;

@interface DDDoubleDateViewController ()<DDSendEngagementViewControllerDelegate>

- (void)loadDataForUser:(DDShortUser*)shortUser;
- (void)dismissUserPopover;
- (void)presentLeftUserPopover;
- (void)presentRightUserPopover;
- (void)switchToNeededMode;
- (void)switchToMode:(DDDoubleDateViewControllerMode)mode;

@property(nonatomic, retain) DDUser *user;
@property(nonatomic, retain) DDUser *wing;

@property(nonatomic, retain) DDTableViewController *tableViewController;

@property(nonatomic, retain) UIView *popover;

@end

@implementation DDDoubleDateViewController

@synthesize user;
@synthesize wing;

@synthesize tableViewController;

@synthesize popover;

@synthesize doubleDate;

@synthesize scrollView;

@synthesize containerHeader;
@synthesize labelLocationMain;
@synthesize labelLocationDetailed;
@synthesize labelDayTime;

@synthesize containerTextView;
@synthesize containerTopImageView;
@synthesize containerBottomImageView;

@synthesize textView;

@synthesize containerPhotos;

@synthesize imageViewFade;

@synthesize buttonInterested;

@synthesize buttonSubNavLeft;
@synthesize buttonSubNavRight;

@synthesize bottomView;
@synthesize centerView;
@synthesize topView;

@synthesize imageViewLeft;
@synthesize imageViewRight;

@synthesize viewInfo;
@synthesize viewSubNavRight;

@synthesize labelTitle;
@synthesize labelLeftUser;
@synthesize labelRightUser;

@synthesize imageViewLeftUserGender;
@synthesize imageViewRightUserGender;

- (id)initWithDoubleDate:(DDDoubleDate*)doubleDate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set navigation item
    self.navigationItem.title = [self.doubleDate title];
    
    //apply autoresizing mask
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    //customize text
    DD_F_TEXT(self.textView);
    
    //customize button
    [self.buttonInterested applyBottomBarDesignWithTitle:self.buttonInterested.titleLabel.text icon:nil background:[UIImage imageNamed:@"lower-button-blue.png"]];
    
    //fill data
    self.labelLocationMain.text = [DDLocationTableViewCell mainTitleForLocation:self.doubleDate.location];
    self.labelLocationDetailed.text = [DDLocationTableViewCell detailedTitleForLocation:self.doubleDate.location];
    self.labelDayTime.text = [DDCreateDoubleDateViewController titleForDDDay:self.doubleDate.dayPref ddTime:self.doubleDate.timePref];
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
    
    //add images
    self.containerTopImageView.image = [[UIImage imageNamed:@"details-bg-top.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 0, 1, 0)];
    self.containerBottomImageView.image = [UIImage imageNamed:@"details-bg-bottom.png"];
    
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
    
    //customize buttons
    DD_F_SUBNAV_TEXT(self.buttonSubNavLeft);
    DD_F_SUBNAV_TEXT(self.buttonSubNavRight);
    [self.buttonSubNavLeft setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"left-subnav-segment-normal.png"]] forState:UIControlStateNormal];
    [self.buttonSubNavLeft setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"left-subnav-segment-selected.png"]] forState:UIControlStateHighlighted];
    [self.buttonSubNavRight setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"right-subnav-segment-normal.png"]] forState:UIControlStateNormal];
    [self.buttonSubNavRight setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"right-subnav-segment-selected.png"]] forState:UIControlStateHighlighted];
    
    [self.buttonSubNavLeft setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.buttonSubNavRight setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    //highlight first button
    [self tabTouched:self.buttonSubNavLeft];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //switch to needed mode
    [self switchToNeededMode];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [doubleDate release];
    [scrollView release];
    [containerHeader release];
    [labelLocationMain release];
    [labelLocationDetailed release];
    [labelDayTime release];
    [containerTextView release];
    [containerTopImageView release];
    [containerBottomImageView release];
    [textView release];
    [containerPhotos release];
    [imageViewFade release];
    [buttonInterested release];
    [buttonSubNavLeft release];
    [buttonSubNavRight release];
    [bottomView release];
    [centerView release];
    [topView release];
    [imageViewLeft release];
    [imageViewRight release];
    [viewInfo release];
    [viewSubNavRight release];
    [tableViewController release];
    [popover release];
    [labelTitle release];
    [labelLeftUser release];
    [labelRightUser release];
    [imageViewLeftUserGender release];
    [imageViewRightUserGender release];
    [super dealloc];
}

#pragma mark -
#pragma mark IB

- (IBAction)leftUserTouched:(DDPhotoView*)sender
{
    //dismiss old
    [self dismissUserPopover];
    
    //present user
    [self presentLeftUserPopover];
}

- (IBAction)rightUserTouched:(DDPhotoView*)sender
{
    //dismiss old
    [self dismissUserPopover];
    
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

- (IBAction)tabTouched:(id)sender
{
    //highlight pressed
    [(DDToggleButton*)sender setToggled:YES];
    
    //unhighlight other
    if (self.buttonSubNavLeft == sender)
        [self.buttonSubNavRight setToggled:NO];
    else if (self.buttonSubNavRight == sender)
        [self.buttonSubNavLeft setToggled:NO];
    
    //save incoming hidden flag
    BOOL viewSubNavRightHidden = self.viewSubNavRight.hidden;
    
    //update visibility
    self.viewInfo.hidden = self.scrollView.hidden = self.buttonSubNavRight.toggled;
    self.viewSubNavRight.hidden = !self.viewInfo.hidden;
    
    //check for change
    if (self.viewSubNavRight.hidden != viewSubNavRightHidden)
    {
        if (self.viewSubNavRight.hidden)
        {
            [self.tableViewController viewWillDisappear:NO];
            [self.tableViewController viewDidDisappear:NO];
        }
        else
        {
            [self.tableViewController viewWillAppear:NO];
            [self.tableViewController viewDidAppear:NO];
        }
    }
}

#pragma mark -
#pragma mark other

- (void)switchToNeededMode
{
    //shown flag
    DDDoubleDateViewControllerMode mode = DDDoubleDateViewControllerModeNone;
    
    //check the user and the wing
    if ([self.doubleDate.relationship isEqualToString:DDDoubleDateRelationshipOwner] ||
        [self.doubleDate.relationship isEqualToString:DDDoubleDateRelationshipWing])
    {
        //check activity status
        if ([self.doubleDate.status isEqualToString:DDDoubleDateStatusEngaged])
            mode = DDDoubleDateViewControllerModeChat;
        else
            mode = DDDoubleDateViewControllerModeIncoming;
    }
    else
    {
        //check interested and accepted
        if ([self.doubleDate.relationship isEqualToString:DDDoubleDateRelationshipAccepted] ||
            [self.doubleDate.relationship isEqualToString:DDDoubleDateRelationshipInterested] ||
            alreadyCreatedEngagement_)
            mode = DDDoubleDateViewControllerModeChat;
    }
    
    //switch to needed mode
    [self switchToMode:mode];
}

- (void)switchToMode:(DDDoubleDateViewControllerMode)mode
{
    //check last mode
    if (lastMode_ == mode)
        return;
    
    //reset all
    if (initialValueInitialized_)
    {
        self.textView.contentOffset = initialTextViewContentOffset_;
        self.scrollView.contentSize = initialScrollViewContentSize_;
        self.containerTextView.frame = initialContainerTextViewFrame_;
        self.containerHeader.center = initialContainerHeaderCenter_;
    }
    else
    {
        initialValueInitialized_ = YES;
        initialTextViewContentOffset_ = self.textView.contentOffset;
        initialScrollViewContentSize_ = self.scrollView.contentSize;
        initialContainerTextViewFrame_ = self.containerTextView.frame;
        initialContainerHeaderCenter_ = self.containerHeader.center;
    }
    
    //save visibility
    BOOL topVisible = (mode != DDDoubleDateViewControllerModeNone);
    BOOL bottomVisible = (mode == DDDoubleDateViewControllerModeNone);
    
    //change visibility
    self.topView.hidden = !topVisible;
    self.bottomView.hidden = !bottomVisible;
    
    //change frame
    CGFloat yt = 0;
    CGFloat yb = bottomVisible?self.bottomView.frame.origin.y:self.bottomView.frame.origin.y+self.bottomView.frame.size.height;
    CGFloat height = yb - yt;
    self.centerView.frame = CGRectMake(self.centerView.frame.origin.x, yt, self.centerView.frame.size.width, height+10);
    
    //change frame
    self.viewInfo.frame = CGRectMake(self.viewInfo.frame.origin.x, topVisible?self.topView.frame.size.height:0, self.viewInfo.frame.size.width, self.view.frame.size.height-(topVisible?self.topView.frame.size.height:0));
    
    //change frame
    CGFloat dh = self.textView.frame.size.height - self.textView.contentSize.height;
    if (dh > 0)
    {
        self.textView.contentOffset = CGPointMake(0, -dh/2);
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.containerPhotos.frame.origin.y+self.containerPhotos.frame.size.height+self.containerHeader.frame.size.height+self.textView.frame.size.height+46);
    }
    else
    {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.containerPhotos.frame.origin.y+self.containerPhotos.frame.size.height+self.containerHeader.frame.size.height+self.textView.contentSize.height+36);
        self.containerTextView.frame = CGRectMake(self.containerTextView.frame.origin.x, self.containerTextView.frame.origin.y, self.containerTextView.frame.size.width, self.containerTextView.frame.size.height-dh);
        self.containerHeader.center = CGPointMake(self.containerHeader.center.x, self.containerHeader.center.y-dh);
    }
    
    //remove all subviews
    while ([[self.viewSubNavRight subviews] count])
        [[[self.viewSubNavRight subviews] lastObject] removeFromSuperview];
    self.tableViewController = nil;
    
    //create needed view controller
    if (mode == DDDoubleDateViewControllerModeIncoming)
    {
        //set title
        [self.buttonSubNavRight setTitle:NSLocalizedString(@"INCOMING", nil) forState:UIControlStateNormal];
        
        //add second tab
        self.tableViewController = [[[DDEngagementsViewController alloc] init] autorelease];
        self.tableViewController.view.frame = CGRectMake(0, 0, self.viewSubNavRight.frame.size.width, self.viewSubNavRight.frame.size.height);
        [(DDEngagementsViewController*)self.tableViewController setDoubleDate:self.doubleDate];
        [self.tableViewController viewDidLoad];
        [self.viewSubNavRight addSubview:self.tableViewController.view];
    }
    else if (mode == DDDoubleDateViewControllerModeChat)
    {
        //set title
        [self.buttonSubNavRight setTitle:NSLocalizedString(@"CHAT", nil) forState:UIControlStateNormal];
    }
}

- (void)dismissUserPopover
{
    if (self.popover)
    {
        [UIView animateWithDuration:0.3f animations:^{
            self.popover.alpha = 0;
        } completion:^(BOOL finished) {
            [self.popover removeFromSuperview];
            self.popover = nil;
        }];
    }
}

- (void)presentPopoverWithUser:(DDUser*)u inView:(UIView*)popoverView
{
    //remove old
    [self.popover removeFromSuperview];
    
    //add view
    self.popover = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dd-popup-darkness.png"]] autorelease];
    self.popover.userInteractionEnabled = YES;
    self.popover.alpha = 0;
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self.popover];
    
    //add button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, self.popover.frame.size.width, self.popover.frame.size.height);
    [button addTarget:self action:@selector(dismissUserPopover) forControlEvents:UIControlEventTouchUpInside];
    [self.popover addSubview:button];
    
    //add bubble
    CGRect bubbleRect = CGRectMake(20, 40, 280, 0);
    DDUserBubble *bubble = [[[DDUserBubble alloc] initWithFrame:bubbleRect] autorelease];
    bubble.userInteractionEnabled = NO;
    bubble.user = u;
    bubble.frame = CGRectMake(bubbleRect.origin.x, bubbleRect.origin.y, bubbleRect.size.width, bubble.height);
    bubble.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    [self.popover addSubview:bubble];
    
    //animate appearing
    [UIView animateWithDuration:0.3f animations:^{
        self.popover.alpha = 1;
    }];
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

- (void)sendEngagementViewControllerDidSendMessage
{
    //save created flag
    alreadyCreatedEngagement_ = YES;
    
    //show succeed message
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Great! You've created engagement.", nil)];
    
    //show completed hud
    [self showCompletedHudWithText:message];
    
    //dismiss
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
    
    //update doubledate in background
    [self.apiController getDoubleDate:self.doubleDate];
}

@end
