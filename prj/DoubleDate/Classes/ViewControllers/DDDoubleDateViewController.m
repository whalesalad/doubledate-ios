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
#import "WEPopoverController.h"
#import "DDShortUser.h"
#import "DDWEImageView.h"

@interface DDDoubleDateViewController ()<WEPopoverControllerDelegate, DDWEImageViewDelegate>

- (void)loadDateForUser:(DDShortUser*)shortUser;
- (void)dismissUserPopover;
- (void)presentLeftUserPopover;
- (void)presentRightUserPopover;
- (void)setFadeViewVisibile:(BOOL)visible;
- (CGSize)bubbleSizeFromXib;

@property(nonatomic, retain) WEPopoverController *popover;

@end

@implementation DDDoubleDateViewController

@synthesize popover;

@synthesize doubleDate;

@synthesize scrollView;

@synthesize labelLocationMain;
@synthesize labelLocationDetailed;
@synthesize labelDayTime;

@synthesize containerTextView;
@synthesize containerTopImageView;
@synthesize containerBottomImageView;

@synthesize textView;

@synthesize containerPhotos;

@synthesize imageViewUserLeft;
@synthesize imageViewUserRight;

@synthesize imageViewUserLeftHighlighted;
@synthesize imageViewUserRightHighlighted;

@synthesize imageViewFade;

@synthesize labelUserLeft;
@synthesize labelUserRight;

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
    
    //fill data
    self.labelLocationMain.text = [DDLocationTableViewCell mainTitleForLocation:self.doubleDate.location];
    self.labelLocationDetailed.text = [DDLocationTableViewCell detailedTitleForLocation:self.doubleDate.location];
    self.labelDayTime.text = [DDCreateDoubleDateViewController titleForDDDay:self.doubleDate.dayPref ddTime:self.doubleDate.timePref];
    self.textView.text = [self.doubleDate details];
    self.labelUserLeft.text = [self.doubleDate user].fullName;
    self.labelUserRight.text = [self.doubleDate wing].fullName;
    
    //check if we should expand text view and scroll view
    CGSize newSizeOfTextView = self.textView.contentSize;
    if (newSizeOfTextView.height > self.textView.frame.size.height)
    {
        CGFloat dh = newSizeOfTextView.height - self.textView.frame.size.height;
        self.containerTextView.frame = CGRectMake(self.containerTextView.frame.origin.x, self.containerTextView.frame.origin.y, self.containerTextView.frame.size.width, self.containerTextView.frame.size.height+dh);
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height+dh);
        self.containerPhotos.frame = CGRectMake(self.containerPhotos.frame.origin.x, self.containerPhotos.frame.origin.y+dh, self.containerPhotos.frame.size.width, self.containerPhotos.frame.size.height);
    }
    
    //add images
    self.containerTopImageView.image = [[UIImage imageNamed:@"dd-indented-text-background-top.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 0, 1, 0)];
    self.containerBottomImageView.image = [UIImage imageNamed:@"dd-indented-text-background-bottom.png"];
    
    //load photos
    [self.imageViewUserLeft reloadFromUrl:[NSURL URLWithString:self.doubleDate.user.photo.downloadUrl]];
    self.imageViewUserLeft.contentMode = UIViewContentModeScaleAspectFill;
    [self.imageViewUserLeft applyMask:[UIImage imageNamed:@"dd-user-photo-mask.png"]];
    [self.imageViewUserRight reloadFromUrl:[NSURL URLWithString:self.doubleDate.wing.photo.downloadUrl]];
    [self.imageViewUserRight applyMask:[UIImage imageNamed:@"dd-user-photo-mask.png"]];
    self.imageViewUserRight.contentMode = UIViewContentModeScaleAspectFill;
    
    //set popover delegates
    self.imageViewUserLeft.popoverDelegate = self;
    self.imageViewUserRight.popoverDelegate = self;
}

- (void)viewDidUnload
{
    [scrollView release], scrollView = nil;
    [labelLocationMain release], labelLocationMain = nil;
    [labelLocationDetailed release], labelLocationDetailed = nil;
    [labelDayTime release], labelDayTime = nil;
    [containerTextView release], containerTextView = nil;
    [containerTopImageView release], containerTopImageView = nil;
    [containerBottomImageView release], containerBottomImageView = nil;
    [textView release], textView = nil;
    [containerPhotos release], containerPhotos = nil;
    [imageViewUserLeft release], imageViewUserLeft = nil;
    [imageViewUserRight release], imageViewUserRight = nil;
    [imageViewUserLeftHighlighted release], imageViewUserLeftHighlighted = nil;
    [imageViewUserRightHighlighted release],  imageViewUserRightHighlighted = nil;
    [imageViewFade release], imageViewFade = nil;
    [labelUserLeft release], labelUserLeft = nil;
    [labelUserRight release], labelUserRight = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [doubleDate release];
    [scrollView release];
    [labelLocationMain release];
    [labelLocationDetailed release];
    [labelDayTime release];
    [containerTextView release];
    [containerTopImageView release];
    [containerBottomImageView release];
    [textView release];
    [containerPhotos release];
    [imageViewUserLeft release];
    [imageViewUserRight release];
    [imageViewUserLeftHighlighted release];
    [imageViewUserRightHighlighted release];
    [imageViewFade release];
    [labelUserLeft release];
    [labelUserRight release];
    [popover release];
    [super dealloc];
}

#pragma mark -
#pragma mark IB

- (IBAction)leftUserTouched:(id)sender
{
    //hide selection
    self.imageViewUserRightHighlighted.hidden = YES;

    //show selection
    self.imageViewUserLeftHighlighted.hidden = !self.imageViewUserLeftHighlighted.hidden;
    
    //dismiss old
    [self dismissUserPopover];
    
    //present user
    if (!self.imageViewUserLeftHighlighted.hidden)
        [self presentLeftUserPopover];
    else
        [self dismissUserPopover];
}

- (IBAction)rightUserTouched:(id)sender
{
    //hide selection
    self.imageViewUserLeftHighlighted.hidden = YES;
    
    //show selection
    self.imageViewUserRightHighlighted.hidden = !self.imageViewUserRightHighlighted.hidden;
    
    //dismiss old
    [self dismissUserPopover];
    
    //present user
    if (!self.imageViewUserRightHighlighted.hidden)
        [self presentRightUserPopover];
    else
        [self dismissUserPopover];
}

#pragma mark -
#pragma mark other

- (void)dismissUserPopover
{
    [self.popover dismissPopoverAnimated:YES];
}

- (void)presentPopoverWithUser:(DDUser*)user inView:(UIView*)popoverView arrowOffset:(CGFloat)arrowOffset
{
    //show fading
    [self setFadeViewVisibile:YES];
    
    //create new
    DDUserBubbleViewController *viewController = [[[DDUserBubbleViewController alloc] init] autorelease];
    viewController.user = user;
    self.popover = [[[WEPopoverController alloc] initWithContentViewController:viewController] autorelease];
    
    //apply container view properties
    self.popover.containerViewProperties = [self.popover defaultContainerViewProperties];
    self.popover.containerViewProperties.arrowMargin = arrowOffset;
#pragma warning popover paddings
//    self.popover.containerViewProperties.leftContentMargin = 10;
//    self.popover.containerViewProperties.rightContentMargin = 10;
//    self.popover.containerViewProperties.topContentMargin = 10;
//    self.popover.containerViewProperties.bottomContentMargin = 10;
//    self.popover.containerViewProperties.leftBgMargin = 10;
//    self.popover.containerViewProperties.rightBgMargin = 10;
//    self.popover.containerViewProperties.topBgMargin = 10;
//    self.popover.containerViewProperties.bottomBgMargin = 10;
    
    //set popover size
    CGSize popoverSize = CGSizeMake(viewController.view.bounds.size.width, viewController.view.bounds.size.height);
    
    //set content size
    self.popover.popoverContentSize = popoverSize;
    
    //set delegate
    self.popover.delegate = self;
    
    //present popover
    [self.popover presentPopoverFromRect:CGRectMake(0, 0, self.popover.popoverContentSize.width, self.popover.popoverContentSize.height) inView:popoverView permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
    //calculate new height
    CGFloat newPopoverHeight = popoverSize.height + viewController.heightOffset;
    newPopoverHeight = MIN(MAX(newPopoverHeight, 70), FLT_MAX);
    self.popover.popoverContentSize = CGSizeMake(popoverSize.width, newPopoverHeight);
    
    //update geometry
    [self.popover repositionPopoverFromRect:CGRectMake(0, 0, self.popover.popoverContentSize.width, self.popover.popoverContentSize.height) inView:popoverView permittedArrowDirections:UIPopoverArrowDirectionDown];
    
    //adjust popover size
    [viewController adjustScrollableArea];
}

- (void)loadDateForUser:(DDShortUser*)shortUser
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Loading...", nil) animated:YES];
    
    //request user
    DDUser *user = [[[DDUser alloc] init] autorelease];
    user.userId = [NSString stringWithFormat:@"%d", [shortUser.identifier intValue]];
    [self.apiController getUser:user];
}

- (void)presentLeftUserPopover
{
    //self that left user requested
    leftUserRequested_ = YES;
    
    //load data
    [self loadDateForUser:self.doubleDate.user];
}

- (void)presentRightUserPopover
{
    //self that left user requested
    leftUserRequested_ = NO;
    
    //load data
    [self loadDateForUser:self.doubleDate.wing];
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

#pragma mark -
#pragma mark WEPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)popoverController
{
    //hide selection
    self.imageViewUserLeftHighlighted.hidden = YES;
    self.imageViewUserRightHighlighted.hidden = YES;
    
    //release popover
    self.popover = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)popoverController
{
    [self setFadeViewVisibile:NO];
    return YES;
}

#pragma mark -
#pragma mark DDWEImageViewDelegate

- (CGRect)displayAreaForPopoverFromView:(UIView*)view
{
    //check left view
    UIView *parentView = self.view;
    CGFloat scrollViewOffset = self.scrollView.contentOffset.y + self.scrollView.frame.size.height - self.scrollView.contentSize.height;
    if (view == self.imageViewUserLeft)
    {
        CGFloat leftAlignment = view.frame.origin.x;
        CGFloat topAlignment = 0-scrollViewOffset;
        CGRect rect = CGRectMake(leftAlignment, topAlignment, [self bubbleSizeFromXib].width, [self bubbleSizeFromXib].height);
		return [parentView convertRect:rect toView:view];
    }
    //right view
    else
    {
        CGFloat rightAlignment = view.frame.origin.x + view.frame.size.width;
        CGFloat topAlignment = 0-scrollViewOffset;
        CGRect rect = CGRectMake(rightAlignment-[self bubbleSizeFromXib].width, topAlignment, [self bubbleSizeFromXib].width, [self bubbleSizeFromXib].height);
        return [parentView convertRect:rect toView:view];
    }
    return CGRectZero;
}

#pragma mark -
#pragma comment DDAPIControllerDelegate

- (void)getUserDidSucceed:(DDUser*)user
{
    //hide hud
    [self hideHud:YES];
    
    //present needed view controller
#pragma warning left/right arrow offsets
    if (leftUserRequested_)
        [self presentPopoverWithUser:user inView:self.imageViewUserLeft arrowOffset:234];
    else
        [self presentPopoverWithUser:user inView:self.imageViewUserRight arrowOffset:88];

}

- (void)getUserDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //hide selection
    self.imageViewUserLeftHighlighted.hidden = YES;
    self.imageViewUserRightHighlighted.hidden = YES;
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
