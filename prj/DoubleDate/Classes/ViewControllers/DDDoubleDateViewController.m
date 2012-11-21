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

@interface DDDoubleDateViewController ()<WEPopoverControllerDelegate>

- (void)loadDateForUser:(DDShortUser*)shortUser;
- (void)dismissUserPopover;
- (void)presentLeftUserPopover;
- (void)presentRightUserPopover;

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
    //create new
    DDUserBubbleViewController *viewController = [[[DDUserBubbleViewController alloc] init] autorelease];
    viewController.user = user;
    self.popover = [[[WEPopoverController alloc] initWithContentViewController:viewController] autorelease];
    
    //apply container view properties
    self.popover.containerViewProperties = [self.popover defaultContainerViewProperties];
    self.popover.containerViewProperties.arrowMargin = arrowOffset;
    
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
    newPopoverHeight = MIN(MAX(newPopoverHeight, 70), 328);
    self.popover.popoverContentSize = CGSizeMake(popoverSize.width, newPopoverHeight);
    
    //update geometry
    [self.popover repositionPopoverFromRect:CGRectMake(0, 0, self.popover.popoverContentSize.width, self.popover.popoverContentSize.height) inView:popoverView permittedArrowDirections:UIPopoverArrowDirectionDown];
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
    return YES;
}

#pragma mark -
#pragma comment DDAPIControllerDelegate

- (void)getUserDidSucceed:(DDUser*)user
{
    //hide hud
    [self hideHud:YES];
    
    //present needed view controller
    if (leftUserRequested_)
        [self presentPopoverWithUser:user inView:self.imageViewUserLeft arrowOffset:228];
    else
        [self presentPopoverWithUser:user inView:self.imageViewUserRight arrowOffset:64];

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
