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
#import "DDUserBubbleViewController.h"
#import "DDShortUser.h"
#import "DDUser.h"
#import "DDSendEngagementViewController.h"
#import "DDButton.h"
#import "DDPhotoView.h"
#import "DDAuthenticationController.h"
#import "DDTools.h"
#import "DDEngagementsViewController.h"
#import "DDDoubleDateBubble.h"

typedef enum
{
    DDDoubleDateViewControllerModeNone = 1<<0,
    DDDoubleDateViewControllerModeIncoming = 1<<1,
    DDDoubleDateViewControllerModeChat = 1<<2
} DDDoubleDateViewControllerMode;

@interface DDDoubleDateViewController ()

- (void)loadDataForUser:(DDShortUser*)shortUser;
- (void)dismissUserPopover;
- (void)presentLeftUserPopover;
- (void)presentRightUserPopover;
- (void)setFadeViewVisibile:(BOOL)visible;
- (CGSize)bubbleSizeFromXib;
- (void)switchToNeededMode;
- (void)switchToMode:(DDDoubleDateViewControllerMode)mode;

@property(nonatomic, retain) DDUser *user;
@property(nonatomic, retain) DDUser *wing;

@property(nonatomic, retain) DDTableViewController *tableViewController;

@end

@implementation DDDoubleDateViewController

@synthesize user;
@synthesize wing;

@synthesize tableViewController;

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

@synthesize photoViewLeft;
@synthesize photoViewRight;

@synthesize viewInfo;
@synthesize viewSubNavRight;

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
    DD_F_WHT_HELV_13_BOLD_BLK_SHAD(self.labelLocationMain);
    DD_F_GRAY_HELV_13_BOLD_BLK_SHAD(self.labelLocationDetailed);
    DD_F_WHT_HELV_13_BOLD_BLK_SHAD(self.labelDayTime);
    DD_F_TEXT(self.textView);
    
    //customize button
    [self.buttonInterested applyBottomBarDesignWithTitle:self.buttonInterested.titleLabel.text icon:nil background:[UIImage imageNamed:@"lower-button-blue.png"]];
    
    //fill data
    self.labelLocationMain.text = [DDLocationTableViewCell mainTitleForLocation:self.doubleDate.location];
    self.labelLocationDetailed.text = [DDLocationTableViewCell detailedTitleForLocation:self.doubleDate.location];
    self.labelDayTime.text = [DDCreateDoubleDateViewController titleForDDDay:self.doubleDate.dayPref ddTime:self.doubleDate.timePref];
    self.textView.text = [self.doubleDate details];
    
    //customize photo views
    self.photoViewLeft.text = [[self.doubleDate user].firstName uppercaseString];
    [self.photoViewLeft applyImage:self.doubleDate.user.photo];
    self.photoViewRight.text = [[self.doubleDate wing].firstName uppercaseString];
    [self.photoViewRight applyImage:self.doubleDate.wing.photo];
    
    //add images
    self.containerTopImageView.image = [[UIImage imageNamed:@"dd-indented-text-background-top.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 0, 1, 0)];
    self.containerBottomImageView.image = [UIImage imageNamed:@"dd-indented-text-background-bottom.png"];
    
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
    DD_F_BUTTON_LARGE(self.buttonSubNavLeft);
    DD_F_BUTTON_LARGE(self.buttonSubNavRight);
    [self.buttonSubNavLeft setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"left-subnav-segment-normal.png"]] forState:UIControlStateNormal];
    [self.buttonSubNavLeft setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"left-subnav-segment-selected.png"]] forState:UIControlStateHighlighted];
    [self.buttonSubNavRight setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"right-subnav-segment-normal.png"]] forState:UIControlStateNormal];
    [self.buttonSubNavRight setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"right-subnav-segment-selected.png"]] forState:UIControlStateHighlighted];
    
    //highligh first button
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
    [photoViewLeft release];
    [photoViewRight release];
    [viewInfo release];
    [viewSubNavRight release];
    [tableViewController release];
    [super dealloc];
}

#pragma mark -
#pragma mark IB

- (IBAction)leftUserTouched:(DDPhotoView*)sender
{
    //apply selection
    sender.highlighted = !sender.highlighted;
    
    //dismiss old
    [self dismissUserPopover];
    
    //present user
    if (sender.highlighted)
        [self presentLeftUserPopover];
}

- (IBAction)rightUserTouched:(DDPhotoView*)sender
{
    //apply selection
    sender.highlighted = !sender.highlighted;
    
    //dismiss old
    [self dismissUserPopover];
    
    //present user
    if (sender.highlighted)
        [self presentRightUserPopover];
}

- (IBAction)interestedTouched:(id)sender
{
    DDSendEngagementViewController *vc = [[[DDSendEngagementViewController alloc] init] autorelease];
    vc.doubleDate = self.doubleDate;
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
            [self.doubleDate.relationship isEqualToString:DDDoubleDateRelationshipInterested])
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
        self.containerPhotos.center = initialContainerPhotosCenter_;
    }
    else
    {
        initialValueInitialized_ = YES;
        initialTextViewContentOffset_ = self.textView.contentOffset;
        initialScrollViewContentSize_ = self.scrollView.contentSize;
        initialContainerTextViewFrame_ = self.containerTextView.frame;
        initialContainerPhotosCenter_ = self.containerPhotos.center;
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
    self.centerView.frame = CGRectMake(self.centerView.frame.origin.x, yt, self.centerView.frame.size.width, height);
    
    //change frame
    self.viewInfo.frame = CGRectMake(self.viewInfo.frame.origin.x, topVisible?self.topView.frame.size.height:0, self.viewInfo.frame.size.width, self.view.frame.size.height-(topVisible?self.topView.frame.size.height:0));
    
    //change frame
    CGFloat dh = self.textView.frame.size.height - self.textView.contentSize.height;
    if (dh > 0)
    {
        self.textView.contentOffset = CGPointMake(0, -dh/2);
    }
    else
    {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.containerHeader.frame.origin.y+self.containerHeader.frame.size.height+self.containerPhotos.frame.size.height+self.textView.contentSize.height+30);
        self.containerTextView.frame = CGRectMake(self.containerTextView.frame.origin.x, self.containerTextView.frame.origin.y, self.containerTextView.frame.size.width, self.containerTextView.frame.size.height-dh);
        self.containerPhotos.center = CGPointMake(self.containerPhotos.center.x, self.containerPhotos.center.y-dh);
    }
    
    //remove all subviews
    while ([[self.viewSubNavRight subviews] count])
        [[[self.viewSubNavRight subviews] lastObject] removeFromSuperview];
    self.tableViewController = nil;
    
    //create needed view controller
    if (mode == DDDoubleDateViewControllerModeIncoming)
    {
        //set title
        [self.buttonSubNavRight setTitle:NSLocalizedString(@"Incoming", nil) forState:UIControlStateNormal];
        
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
        [self.buttonSubNavRight setTitle:NSLocalizedString(@"Chat", nil) forState:UIControlStateNormal];
    }
}

- (void)dismissUserPopover
{
}

- (void)presentPopoverWithUser:(DDUser*)u inView:(UIView*)popoverView arrowOffset:(CGFloat)arrowOffset
{
    //show fading
    [self setFadeViewVisibile:YES];
    
    //add view
    UIView *mainView = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    mainView.backgroundColor = [UIColor blackColor];
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:mainView];
    
    //add bubble
    DDDoubleDateBubble *bubble = [[[DDDoubleDateBubble alloc] initWithFrame:CGRectMake(20, 40, 280, 300)] autorelease];
    bubble.center = CGPointMake(mainView.frame.size.width/2, mainView.frame.size.height/2);
    [mainView addSubview:bubble];
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

- (void)setFadeViewVisibile:(BOOL)visible
{
    [UIView animateWithDuration:0.3f animations:^{
        self.imageViewFade.alpha = visible?1:0;
    }];
}

- (CGSize)bubbleSizeFromXib
{
    static CGSize _bubbleSize;
    static BOOL _bubbleSizeInitialized = NO;
    if (!_bubbleSizeInitialized)
    {
        _bubbleSizeInitialized = YES;
        _bubbleSize = [[[DDUserBubbleViewController alloc] init] autorelease].view.frame.size;
    }
    return _bubbleSize;
}

//#pragma mark -
//#pragma mark WEPopoverControllerDelegate
//
//- (void)popoverControllerDidDismissPopover:(WEPopoverController *)popoverController
//{
//    //hide selection
//    self.photoViewLeft.highlighted = NO;
//    self.photoViewRight.highlighted = NO;
//    
//    //release popover
//    self.popover = nil;
//}
//
//- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)popoverController
//{
//    [self setFadeViewVisibile:NO];
//    return YES;
//}
//
//#pragma mark -
//#pragma mark DDWEImageViewDelegate
//
//- (CGRect)displayAreaForPopoverFromView:(UIView*)view
//{
//    //init data
//    UIView *parentView = self.view;
//    CGFloat scrollViewOffset = 0;
//    if (scrollView.contentOffset.y > 0)
//        scrollViewOffset = self.scrollView.contentOffset.y + self.scrollView.frame.size.height - self.scrollView.contentSize.height;
//    
//    //check left view
//    if (view == self.photoViewLeft)
//    {
//        CGFloat leftAlignment = view.frame.origin.x;
//        CGFloat topAlignment = 0-scrollViewOffset;
//        CGRect rect = CGRectMake(leftAlignment, topAlignment, [self bubbleSizeFromXib].width, [self bubbleSizeFromXib].height);
//		return [parentView convertRect:rect toView:view];
//    }
//    //right view
//    else
//    {
//        CGFloat rightAlignment = view.frame.origin.x + view.frame.size.width;
//        CGFloat topAlignment = 0-scrollViewOffset;
//        CGRect rect = CGRectMake(rightAlignment-[self bubbleSizeFromXib].width, topAlignment, [self bubbleSizeFromXib].width, [self bubbleSizeFromXib].height);
//        return [parentView convertRect:rect toView:view];
//    }
//    return CGRectZero;
//}

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
            [self presentPopoverWithUser:u inView:self.photoViewLeft arrowOffset:212];
        else
            [self presentPopoverWithUser:u inView:self.photoViewRight arrowOffset:52];
    }
}

- (void)getUserDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //hide selection
    self.photoViewLeft.highlighted = NO;
    self.photoViewRight.highlighted = NO;
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
