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

typedef enum
{
    DDDoubleDateViewControllerModeNone = 1<<0,
    DDDoubleDateViewControllerModeIncoming = 1<<1,
    DDDoubleDateViewControllerModeChat = 1<<2
} DDDoubleDateViewControllerMode;

@interface DDDoubleDateViewController ()<DDSendEngagementViewControllerDelegate, UIScrollViewDelegate>

- (void)loadDataForUser:(DDShortUser*)shortUser;
- (void)dismissUserPopover;
- (void)presentLeftUserPopover;
- (void)presentRightUserPopover;
- (void)switchToNeededMode;
- (void)switchToMode:(DDDoubleDateViewControllerMode)mode;
- (void)updateEngagementsTab;

@property(nonatomic, retain) DDUser *user;
@property(nonatomic, retain) DDUser *wing;

@property(nonatomic, retain) UIViewController *rightViewController;

@property(nonatomic, retain) UIView *popover;

@end

@implementation DDDoubleDateViewController

@synthesize user;
@synthesize wing;

@synthesize rightViewController;

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

@synthesize labelTitle;
@synthesize textView;

@synthesize labelLeftUser;
@synthesize labelRightUser;

@synthesize imageViewLeftUserGender;
@synthesize imageViewRightUserGender;

@synthesize leftView;
@synthesize rightView;

@synthesize labelButtonInterestedDetailed;
@synthesize labelButtonInterestedMain;

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
    self.navigationItem.title = NSLocalizedString(@"Details", nil);
    
    //set title label
    self.labelTitle.text = [self.doubleDate title];
    
    //customize text
    DD_F_TEXT(self.textView);
    
    //customize intereseted button
    self.labelButtonInterestedMain.text = [NSString stringWithFormat:@"%@ + %@", [self.doubleDate.user.firstName uppercaseString], [self.doubleDate.wing.firstName uppercaseString]];
    [self.buttonInterested setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"large-lower-button.png"]] forState:UIControlStateNormal];
    
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
    
    //request information
    if ([self.doubleDate.relationship isEqualToString:DDDoubleDateRelationshipOwner] ||
        [self.doubleDate.relationship isEqualToString:DDDoubleDateRelationshipWing])
        [self.apiController getEngagementsForDoubleDate:self.doubleDate];
    else if ([self.doubleDate.relationship isEqualToString:DDDoubleDateRelationshipEngaged])
        [self.apiController getEngagementForDoubleDate:self.doubleDate];
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
    [engagements_ release];
    [doubleDate release];
    [rightViewController release];
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
    [labelTitle release];
    [textView release];
    [labelLeftUser release];
    [labelRightUser release];
    [imageViewLeftUserGender release];
    [imageViewRightUserGender release];
    [leftView release];
    [rightView release];
    [labelButtonInterestedDetailed release];
    [labelButtonInterestedMain release];
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

#pragma mark -
#pragma mark other

- (void)segmentedControlTouched:(UISegmentedControl*)sender
{
    //check for incoming messages
    if (sender.selectedSegmentIndex == 1)
    {
        if (lastMode_ == DDDoubleDateViewControllerModeIncoming)
        {
            //check if we need to create a tab
            if (![self.rightViewController isKindOfClass:[DDEngagementsViewController class]])
            {
                //remove previous
                [self.rightViewController.view removeFromSuperview];
                self.rightViewController = nil;
                
                //create view controller
                self.rightViewController = [[[DDEngagementsViewController alloc] init] autorelease];
                self.rightViewController.view.frame = CGRectMake(0, 0, self.rightView.frame.size.width, self.rightView.frame.size.height);
                [(DDEngagementsViewController*)self.rightViewController setDoubleDate:self.doubleDate];
                [self.rightViewController viewDidLoad];
                [self.rightView addSubview:self.rightViewController.view];
            }
        }
        else if (lastMode_ == DDDoubleDateViewControllerModeChat)
        {
            //check if we need to create a tab
            if (![self.rightViewController isKindOfClass:[DDChatViewController class]])
            {
                //remove previous
                [self.rightViewController.view removeFromSuperview];
                self.rightViewController = nil;
                
                //create engagement object
                assert([engagements_ count] == 1);
                DDEngagement *engagement = [engagements_ lastObject];
#warning this is temporary fix
                engagement.activityId = self.doubleDate.identifier;
                
                //add second tab
                self.rightViewController = [[[DDChatViewController alloc] init] autorelease];
                self.rightViewController.view.frame = CGRectMake(0, 0, self.rightView.frame.size.width, self.rightView.frame.size.height);
                [(DDChatViewController*)self.rightViewController setEngagement:engagement];
                [self.rightViewController viewDidLoad];
                [(DDChatViewController*)self.rightViewController setWeakParentViewController:self];
                [self.rightView addSubview:self.rightViewController.view];
            }
        }
    }
    
    //update visibility
    self.leftView.hidden = sender.selectedSegmentIndex == 1;
    self.rightView.hidden = sender.selectedSegmentIndex != 1;
    if (self.rightView.hidden)
    {
        [self.rightViewController viewWillDisappear:NO];
        [self.rightViewController viewDidDisappear:NO];
    }
    else
    {
        [self.rightViewController viewWillAppear:NO];
        [self.rightViewController viewDidAppear:NO];
    }
}

- (void)switchToNeededMode
{
    //shown flag
    DDDoubleDateViewControllerMode mode = DDDoubleDateViewControllerModeNone;
    
    //check the user and the wing
    if ([self.doubleDate.relationship isEqualToString:DDDoubleDateRelationshipOwner] ||
        [self.doubleDate.relationship isEqualToString:DDDoubleDateRelationshipWing])
    {
        //show incoming
        mode = DDDoubleDateViewControllerModeIncoming;
    }
    else
    {
        //check interested and accepted
        if ([self.doubleDate.relationship isEqualToString:DDDoubleDateRelationshipEngaged] ||
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
    
    //save last mode
    lastMode_ = mode;
    
    //save visibility
    BOOL bottomVisible = (mode == DDDoubleDateViewControllerModeNone);
    
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
    
    //remove all subviews of right view
    while ([[self.rightView subviews] count])
            [[[self.rightView subviews] lastObject] removeFromSuperview];
    self.rightViewController = nil;
    
    //create needed view controller
    if (mode == DDDoubleDateViewControllerModeNone)
    {
        //unset title view
        self.navigationItem.titleView = nil;
    }
    if (mode == DDDoubleDateViewControllerModeIncoming)
    {
        //add segmeneted control
        NSMutableArray *items = [NSMutableArray array];
        [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"Details", nil) width:0]];
        [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"Incoming", nil) width:0]];
        DDSegmentedControl *segmentedControl = [[[DDSegmentedControl alloc] initWithItems:items style:DDSegmentedControlStyleSmall] autorelease];
        segmentedControl.selectedSegmentIndex = self.rightView.hidden?0:1;
        self.navigationItem.titleView = segmentedControl;
        [segmentedControl addTarget:self action:@selector(segmentedControlTouched:) forControlEvents:UIControlEventValueChanged];
    }
    else if (mode == DDDoubleDateViewControllerModeChat)
    {
        //add segmeneted control
        NSMutableArray *items = [NSMutableArray array];
        [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"Details", nil) width:0]];
        [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"Chat", nil) width:0]];
        DDSegmentedControl *segmentedControl = [[[DDSegmentedControl alloc] initWithItems:items style:DDSegmentedControlStyleSmall] autorelease];
        segmentedControl.selectedSegmentIndex = self.rightView.hidden?0:1;
        self.navigationItem.titleView = segmentedControl;
        [segmentedControl addTarget:self action:@selector(segmentedControlTouched:) forControlEvents:UIControlEventValueChanged];
    }
    
    //update engagements tab
    [self updateEngagementsTab];
}

- (void)updateEngagementsTab
{
    if ([self.navigationItem.titleView isKindOfClass:[UISegmentedControl class]])
    {
        [(UISegmentedControl*)self.navigationItem.titleView setEnabled:[engagements_ count]>0 forSegmentAtIndex:1];
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
    //check user
    assert(self.user == u || self.wing == u);
    
    //remove old
    [self.popover removeFromSuperview];
    
    //add view
    self.popover = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dd-popup-darkness.png"]] autorelease];
    self.popover.userInteractionEnabled = YES;
    self.popover.alpha = 0;
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self.popover];
    
    //flag of both users
    BOOL bothUsers = self.user && self.wing;
    
    //add scroll view
    UIScrollView *sv = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.popover.bounds.size.width, self.popover.bounds.size.height)] autorelease];
    sv.contentSize = CGSizeMake(self.popover.bounds.size.width*(bothUsers?2:1), self.popover.bounds.size.height);
    sv.pagingEnabled = bothUsers;
    sv.delegate = self;
    sv.showsHorizontalScrollIndicator = NO;
    [self.popover addSubview:sv];
    
    //add tap recognizer
    UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissUserPopover)] autorelease];
    [sv addGestureRecognizer:tapRecognizer];
    
    //add gesture recognizer for close
    UISwipeGestureRecognizer *swipeRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissUserPopover)] autorelease];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [sv addGestureRecognizer:swipeRecognizer];
    
    //add page control
    UIPageControl *pageControl = [[[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 80, 36)] autorelease];
    // XXX Controlling page position
    pageControl.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height-32);
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.numberOfPages = (bothUsers?2:1);
    [pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
    [self.popover addSubview:pageControl];
    
    //add bubbles
    CGRect bubbleRect = CGRectMake(25, 40, 270, 0);
    if (bothUsers)
    {
        //create bubble
        {
            DDUserBubble *bubble = [[[DDUserBubble alloc] initWithFrame:bubbleRect] autorelease];
            bubble.users = [NSArray arrayWithObject:self.user];
            bubble.frame = CGRectMake(bubbleRect.origin.x, bubbleRect.origin.y, bubbleRect.size.width, bubble.height);
            bubble.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
            [sv addSubview:bubble];
        }
        
        //create bubble
        {
            DDUserBubble *bubble = [[[DDUserBubble alloc] initWithFrame:bubbleRect] autorelease];
            bubble.users = [NSArray arrayWithObject:self.wing];
            bubble.frame = CGRectMake(bubbleRect.origin.x, bubbleRect.origin.y, bubbleRect.size.width, bubble.height);
            bubble.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2+[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/2);
            [sv addSubview:bubble];
        }
        
        //set needed current page
        pageControl.currentPage = (u==self.user)?0:1;
        
        //check for needed page
        if (pageControl.currentPage == 1)
            sv.contentOffset = CGPointMake([UIScreen mainScreen].bounds.size.width, 0);
    }
    else
    {
        //create bubble
        {
            DDUserBubble *bubble = [[[DDUserBubble alloc] initWithFrame:bubbleRect] autorelease];
            bubble.users = [NSArray arrayWithObject:u];
            bubble.frame = CGRectMake(bubbleRect.origin.x, bubbleRect.origin.y, bubbleRect.size.width, bubble.height);
            bubble.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
            [sv addSubview:bubble];
        }
    }
    
    //animate appearing
    [UIView animateWithDuration:0.3f animations:^{
        self.popover.alpha = 1;
    }];
}

- (void)pageChanged:(UIPageControl*)sender
{
    //get scroll view
    UIScrollView *sv = nil;
    for (UIScrollView *v in [sender.superview subviews])
    {
        if ([v isKindOfClass:[UIScrollView class]])
            sv = v;
    }
    
    //set content offset
    [sv scrollRectToVisible:CGRectMake(sender.currentPage * sv.frame.size.width, 0, sv.frame.size.width, sv.frame.size.height) animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender
{
    //get page view
    UIPageControl *pc = nil;
    for (UIPageControl *v in [sender.superview subviews])
    {
        if ([v isKindOfClass:[UIPageControl class]])
            pc = v;
    }
    
    //set current page
    pc.currentPage = floor((sender.contentOffset.x - sender.frame.size.width) / 2 / sender.frame.size.width + 1);
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

- (void)getEngagementsForDoubleDateSucceed:(NSArray *)engagements
{
    //save engagmgents
    [engagements_ release];
    engagements_ = [engagements retain];
    
    //update segmented control
    [self updateEngagementsTab];
}

- (void)getEngagementsForDoubleDateDidFailedWithError:(NSError *)error
{
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)getEngagementForDoubleDateSucceed:(DDEngagement *)engagement
{
    [self getEngagementsForDoubleDateSucceed:[NSArray arrayWithObject:engagement]];
}

- (void)getEngagementForDoubleDateDidFailedWithError:(NSError *)error
{
    [self getEngagementsForDoubleDateDidFailedWithError:error];
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
