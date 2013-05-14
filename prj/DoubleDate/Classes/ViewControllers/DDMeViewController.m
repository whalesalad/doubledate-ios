//
//  DDMeViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDMeViewController.h"
#import "DDUser.h"
#import "DDAuthenticationController.h"
#import "DDDialog.h"
#import "DDDialogAlertView.h"
#import "DDImageView.h"
#import "DDObjectsController.h"
#import "DDAppDelegate+NavigationMenu.h"
#import "DDAppDelegate+Navigation.h"
#import "DDEditProfileViewController.h"
#import "DDBarButtonItem.h"
#import "DDImageEditDialogView.h"
#import "DDImage.h"
#import "DDTools.h"
#import "UIImage+DD.h"
#import "DDImageView.h"
#import "DDWingTableViewCell.h"
#import "DDCreateDoubleDateViewController.h"
#import "DDDoubleDateTableViewCell.h"
#import "DDDoubleDateViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>

#define kTagActionSheetEdit 1
#define kTagActionSheetChangePhoto 2
#define kTagLoadingSpinner 3

@interface DDMeViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DDImageEditDialogViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, retain) DDImageEditDialogView *imageEditView;

@property(nonatomic, assign) BOOL isDatesViewFullScreen;

@end

@implementation DDMeViewController

@synthesize user;

@synthesize tableView;
@synthesize textView;
@synthesize viewTop;
@synthesize viewBottom;
@synthesize imageViewPoster;
@synthesize labelTitle;
@synthesize labelLocation;
@synthesize imageViewGender;
@synthesize buttonEditProfile;
@synthesize buttonEditPhoto;
@synthesize barYourDates;
@synthesize labelYourDates;
@synthesize buttonYourDates;
@synthesize viewNoDates;
@synthesize viewNoBio;

@synthesize imageEditView;
@synthesize isDatesViewFullScreen;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageViewUpdateNotification:) name:DDImageViewUpdateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectUpdatedNotification:) name:DDObjectsControllerDidUpdateObjectNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //localize
    [self.viewNoBio setTitle:NSLocalizedString(@"Your bio is empty, tap to edit", @"Account Profile: No bio button") forState:UIControlStateNormal];
    self.viewNoDates.text = NSLocalizedString(@"You haven't posted any yet", @"Account Profile: No dates label");
    [self.buttonEditProfile setTitle:NSLocalizedString(@"Edit Profile", @"Account Profile: Edit profile button") forState:UIControlStateNormal];
    
    //add right button
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"button-gear.png"] target:self action:@selector(editTouched:)];
    
    //apply table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [DDTools styleDualUserView:self.viewTop];
    
    //unset colors
    self.labelTitle.backgroundColor = [UIColor clearColor];
    self.labelLocation.backgroundColor = [UIColor clearColor];
    self.viewNoBio.backgroundColor = [UIColor clearColor];
    self.viewNoDates.backgroundColor = [UIColor clearColor];
    
    self.viewBottom.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dd-pinstripe-background"]];
    
    self.barYourDates.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"doubeldate-bar-bg.png"]];
    
    //add button handlers
    [self.buttonEditProfile addTarget:self action:@selector(editProfileTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonEditPhoto addTarget:self action:@selector(changePhotoTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonYourDates addTarget:self action:@selector(addDateTouched) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check the same user
    if ([[[DDAuthenticationController currentUser] userId] intValue] == [user.userId intValue])
    {
        //show welcome dialog only once
        static BOOL welcomeDialogShown = NO;
        if (!welcomeDialogShown)
        {
            //set flag
            welcomeDialogShown = YES;
            
            //check for new user
            if ([DDAuthenticationController isNewUser])
            {
                //create fake dialog
                DDDialog *dialog = [[[DDDialog alloc] init] autorelease];
                dialog.upperText = NSLocalizedString(@"Welcome to DoubleDate!", @"Welcome dialog title");
                dialog.description = NSLocalizedString(@"Here's 500 Coins for joining! Now go invite some wings,\npost some DoubleDates,\nand have fun!", @"Welcome dialog description");
                dialog.coins = [NSNumber numberWithInt:500];
                dialog.dismissText = NSLocalizedString(@"Get Started", @"Welcome dialog button text");
                
                //create alert
                [[[[DDDialogAlertView alloc] initWithDialog:dialog] autorelease] show];
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    //make super
    [super viewWillAppear:animated];
    
    //request new dates
    [self.apiController getMyDoubleDates];

    //reinit fields
    [self reinitTitle];
    [self reinitPoster];
    [self reinitBio];
    [self reinitLocation];
    [self reinitDates];
}

- (void)reinitTitle
{
    //update navigation title
    [self setMeNavigationItemTitle];
    
    //update gender
    self.imageViewGender.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-indicator-small.png", self.user.gender]];
    
    //make correct positioning
    CGFloat dx = CGRectGetMinX(self.imageViewGender.frame) - CGRectGetMaxX(self.labelTitle.frame);
    
    //update name
    CGFloat labelWidth = MIN([[DDWingTableViewCell titleForUser:user] sizeWithFont:self.labelTitle.font].width, 160);
    self.labelTitle.frame = CGRectMake(self.labelTitle.frame.origin.x, self.labelTitle.frame.origin.y, labelWidth, self.labelTitle.frame.size.height);
    self.labelTitle.text = [DDWingTableViewCell titleForUser:user];
    
    //layout gender
    self.imageViewGender.frame = CGRectMake( CGRectGetMaxX(self.labelTitle.frame) + dx, self.imageViewGender.frame.origin.y, self.imageViewGender.frame.size.width, self.imageViewGender.frame.size.height);
}

- (void)reinitPoster
{
    //set poster
    if (user.photo.squareUrl)
        [imageViewPoster reloadFromUrl:[NSURL URLWithString:user.photo.squareUrl]];
}

- (void)reinitBio
{    
    //update visibility
    self.viewNoBio.hidden = [self.user.bio length] > 0;
    self.textView.hidden = !self.viewNoBio.hidden;
    
    //change the text
    self.textView.text = self.user.bio;
    
    //change the geometry
//    CGFloat neededHeightOfTextView = [self.textView sizeThatFits:self.textView.contentSize].height;
//    CGFloat realHeightOfTextView = self.textView.frame.size.height;
//    CGFloat dy = neededHeightOfTextView - realHeightOfTextView;
//    [self.textView sizeThatFits:self.textView.contentSize];
    CGRect frame = self.textView.frame;
    UIEdgeInsets inset = self.textView.contentInset;
    frame.size.height = self.textView.contentSize.height + inset.top + inset.bottom;
    self.textView.frame = frame;
    
    //change the frame of top view
//    self.viewTop.frame = CGRectMake(self.viewTop.frame.origin.x, self.viewTop.frame.origin.y, self.viewTop.frame.size.width, self.viewTop.frame.size.height + dy);
    
    self.viewBottom.frame = CGRectMake(self.viewBottom.frame.origin.x, // x
                                       self.isDatesViewFullScreen ? 0 : [self verticalOffsetForBottomView], // y
                                       self.viewBottom.frame.size.width, // w
                                       self.isDatesViewFullScreen ? self.view.bounds.size.height : self.view.bounds.size.height - [self verticalOffsetForBottomView] // h
                                       );
}

- (void)reinitLocation
{
    //set location
    self.labelLocation.text = [[user location] name];
}

- (void)reinitDates
{
    //update table view
    [self.tableView reloadData];
    
    //update visibility
    self.viewNoDates.hidden = !((doubleDatesMine_ != nil) && ([doubleDatesMine_ count] == 0));
    self.tableView.hidden = !([doubleDatesMine_ count] > 0);
}

- (CGFloat)verticalOffsetForBottomView
{
    return CGRectGetMaxY(self.viewTop.frame) + self.textView.frame.size.height + 28;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [user release];
    [tableView release];
    [textView release];
    [viewTop release];
    [viewBottom release];
    [imageViewPoster release];
    [labelTitle release];
    [labelLocation release];
    [imageViewGender release];
    [buttonEditProfile release];
    [buttonEditPhoto release];
    [barYourDates release];
    [labelYourDates release];
    [buttonYourDates release];
    [viewNoDates release];
    [viewNoBio release];
    [imageEditView release];
    [doubleDatesMine_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (void)editTouched:(id)sender
{
    [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] dismissNavigationMenu];
    
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Edit Profile", nil), NSLocalizedString(@"Change Photo", nil), NSLocalizedString(@"Logout", nil), nil] autorelease];
    actionSheet.tag = kTagActionSheetEdit;
    [actionSheet showInView:self.view];
}

- (void)addDateTouched
{
    [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] dismissNavigationMenu];
    DDCreateDoubleDateViewController *viewController = [[[DDCreateDoubleDateViewController alloc] init] autorelease];
    [[(DDAppDelegate*)[[UIApplication sharedApplication] delegate] topNavigationController] presentViewController:[[[UINavigationController alloc] initWithRootViewController:viewController] autorelease] animated:YES completion:^{
    }];
}

- (void)editProfileTouched
{
    DDEditProfileViewController *viewController = [[[DDEditProfileViewController alloc] initWithUser:self.user] autorelease];
    [self.navigationController presentViewController:[[[DDNavigationController alloc] initWithRootViewController:viewController] autorelease] animated:YES completion:^{
    }];
    viewController.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Cancel", nil) target:self action:@selector(dismissModalViewController)];
}

- (void)dismissModalViewController
{
    //dismiss view controller
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)changePhotoTouched
{
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Choose a Photo", @"Choose photo from library.")];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Take a Photo", @"Take photo with camera.")];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Pull Facebook Photo", @"Get users current FB photo.")];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    [actionSheet setCancelButtonIndex:[actionSheet numberOfButtons]-1];
    actionSheet.tag = kTagActionSheetChangePhoto;
    [actionSheet showInView:self.view];
}

- (void)logoutTouched
{
    [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] logout];
}

- (BOOL)loadImageFromSourceType:(UIImagePickerControllerSourceType)type
{
    if ([[UIImagePickerController availableMediaTypesForSourceType:type] containsObject:(NSString *)kUTTypeImage])
    {
        UIImagePickerController *imagePicker = [[[UIImagePickerController alloc] init] autorelease];
        imagePicker.delegate = self;
        imagePicker.sourceType = type;
        imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        [self.navigationController presentViewController:imagePicker animated:YES completion:^{
        }];
        return YES;
    }
    return NO;
}

- (void)changePhotoChooseTouched
{
    [self loadImageFromSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)changePhotoCreateTouched
{
    [self loadImageFromSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (void)changePhotoPullTouched
{
    //hide avatar
    [self setAvatarShown:NO];
    
    //cancel previous request
    [self.apiController cancelRequest:updatePhotoRequest_];
    
    //create new request
    [self.apiController getPhotoForMeFromFacebook];
}

- (void)setAvatarShown:(BOOL)shown
{
    //animate loading
    UIActivityIndicatorView *loadingView = (UIActivityIndicatorView*)[self.imageViewPoster.superview viewWithTag:kTagLoadingSpinner];
    if (!loadingView)
    {
        loadingView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        loadingView.tag = kTagLoadingSpinner;
        loadingView.center = self.imageViewPoster.center;
        loadingView.hidesWhenStopped = YES;
        [self.imageViewPoster.superview addSubview:loadingView];
    }
    
    //stop animating before fading
    if (shown)
    {
        [loadingView removeFromSuperview];
        loadingView = nil;
    }
    
    //hide or show avatar
    [UIView animateWithDuration:0.5f animations:^{
        
        //update alpha
        self.imageViewPoster.alpha = shown?1:0;
    } completion:^(BOOL finished) {
        
        //start animating after fading
        if (!shown)
        {
            UIActivityIndicatorView *loadingView = (UIActivityIndicatorView*)[self.imageViewPoster.superview viewWithTag:kTagLoadingSpinner];
            [loadingView startAnimating];
        }
    }];
}

- (void)setMeNavigationItemTitle
{
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Hi %@!", @"Hi NAME! on users own profile view."), user.firstName];
}

- (void)updateAvatarWithImage:(UIImage*)image
{
    //check new image
    if (!image)
        return;
    
    //hide avatar
    [self setAvatarShown:NO];
    
    //cancel previous request
    [self.apiController cancelRequest:updatePhotoRequest_];
    
    //create new request
    updatePhotoRequest_ = [self.apiController updatePhotoForMe:image];
}

- (void)presentCropUIForImage:(UIImage*)image
{
    //dismiss old one
    [self.imageEditView dismiss];
    
    //create edit dialog
    self.imageEditView = [[[DDImageEditDialogView alloc] initWithUIImage:image inImageView:self.imageViewPoster] autorelease];
    self.imageEditView.delegate = self;
    [self.imageEditView showInView:self.view];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kTagActionSheetEdit)
    {
        switch (buttonIndex) {
            case 0:
                [self editProfileTouched];
                break;
            case 1:
                [self changePhotoTouched];
                break;
            case 2:
                [self logoutTouched];
                break;
            default:
                break;
        }
    }
    else if (actionSheet.tag == kTagActionSheetChangePhoto)
    {
        switch (buttonIndex) {
            case 0:
                [self.imageEditView dismiss];
                [self changePhotoChooseTouched];
                break;
            case 1:
                [self.imageEditView dismiss];
                [self changePhotoCreateTouched];
                break;
            case 2:
                [self.imageEditView dismiss];
                [self changePhotoPullTouched];
                break;
            default:
                break;
        }
    }
}

- (void)imageViewUpdateNotification:(NSNotification*)notification
{
    if ([notification object] == self.imageViewPoster)
        [self setAvatarShown:YES];
}

- (void)objectUpdatedNotification:(NSNotification*)notification
{
    //save request method
    RKRequestMethod method = [[[notification userInfo] objectForKey:DDObjectsControllerDidUpdateObjectRestKitMethodUserInfoKey] intValue];
    
    //check object
    if ([[notification object] isKindOfClass:[DDUser class]])
    {
        DDUser *userToUpdate = (DDUser*)[notification object];
        if ([[userToUpdate userId] intValue] == [self.user.userId intValue])
            self.user = userToUpdate;
    }
    else if ([[notification object] isKindOfClass:[DDDoubleDate class]])
    {
        if (method == RKRequestMethodPOST)
        {
            //add object
            [doubleDatesMine_ addObject:[notification object]];
            
            //reload the whole data
            [self reinitDates];
        }
    }
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //save image
    UIImage *image = nil;
    
    //check for image
    if (CFStringCompare((CFStringRef)[info objectForKey:UIImagePickerControllerMediaType], kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        //save image
        if ([info objectForKey:UIImagePickerControllerEditedImage])
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        else if ([info objectForKey:UIImagePickerControllerOriginalImage])
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //fix orientation
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
            image = [image fixOrientation];
        
        //show crop
        if (image)
            [self presentCropUIForImage:image];
    }
    
    //dismiss view controller
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark -
#pragma mark API

- (void)updatePhotoForMeSucceed:(DDImage*)photo
{
    //update url only if updated not after cropping
    if ([self.apiController isRequestExist:updatePhotoRequest_])
        [self.imageViewPoster reloadFromUrl:[NSURL URLWithString:photo.squareUrl]];
        
    //update object
    self.user.photo = photo;
    
    //update shared values
    if ([[[DDAuthenticationController currentUser] userId] intValue] == [user.userId intValue])
        [DDAuthenticationController setCurrentUser:self.user];
}

- (void)updatePhotoForMeDidFailedWithError:(NSError*)error
{
    //show avatar
    [self setAvatarShown:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)getPhotoForMeFromFacebookSucceed:(DDImage*)photo
{
    //dismiss previous one
    [self.imageEditView dismiss];
    
    //create edit dialog
    self.imageEditView = [[[DDImageEditDialogView alloc] initWithDDImage:photo inImageView:self.imageViewPoster] autorelease];
    self.imageEditView.delegate = self;
    [self.imageEditView showInView:self.view];
    
    //show avatar
    [self setAvatarShown:YES];
}

- (void)getPhotoForMeFromFacebookDidFailedWithError:(NSError*)error
{
    //show avatar
    [self setAvatarShown:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)updatePhotoForMeFromFacebookSucceed:(DDImage*)photo
{
    [self updatePhotoForMeSucceed:photo];
}

- (void)updatePhotoForMeFromFacebookDidFailedWithError:(NSError*)error
{
    [self updatePhotoForMeDidFailedWithError:error];
}

#pragma mark -
#pragma mark DDImageEditDialogViewDelegate

- (void)imageEditDialogViewDidCancel:(DDImageEditDialogView*)sender
{
    
}

- (void)imageEditDialogView:(DDImageEditDialogView*)sender didCutImage:(UIImage*)image inRect:(CGRect)rect
{
    //cut image
    UIImage *cutImage = [image cutImageWithRect:rect];
    
    //update poster
    self.imageViewPoster.image = cutImage;
    
    //update photo
    if (sender.uiImage)
        [self.apiController updatePhotoForMe:cutImage];
    else if (sender.ddImage)
        [self.apiController updatePhotoForMeFromFacebookWithCropRect:rect];
}

- (void)imageEditDialogViewWillShow:(DDImageEditDialogView*)sender
{
    self.navigationItem.title = NSLocalizedString(@"Resize & Position", nil);
}

- (void)imageEditDialogViewDidShow:(DDImageEditDialogView*)sender
{
}

- (void)imageEditDialogViewWillHide:(DDImageEditDialogView*)sender
{
    [self setMeNavigationItemTitle];
}

- (void)imageEditDialogViewDidHide:(DDImageEditDialogView*)sender
{
    if (sender == self.imageEditView)
        self.imageEditView = nil;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get double date
    DDDoubleDate *doubleDate = [doubleDatesMine_ objectAtIndex:indexPath.row];
    
    //show hud
    [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
    
    //get full information
    [self.apiController getDoubleDate:doubleDate];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DDDoubleDateTableViewCell height];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [doubleDatesMine_ count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //save class
    Class cellClass = [DDDoubleDateTableViewCell class];
    
    //create cell
    DDDoubleDateTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:[cellClass description]];
    if (!cell)
        cell = [[[UINib nibWithNibName:[cellClass description] bundle:nil] instantiateWithOwner:aTableView options:nil] objectAtIndex:0];
    
    //apply data
    if (indexPath.row < [doubleDatesMine_ count])
        cell.doubleDate = [doubleDatesMine_ objectAtIndex:indexPath.row];
    else
        cell.doubleDate = nil;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //get doubledate
        DDDoubleDate *doubleDate = [[doubleDatesMine_ objectAtIndex:indexPath.row] retain];
        
        //remove sliently
        [doubleDatesMine_ removeObject:doubleDate];
        
        //reload data
        [self reinitDates];
        
        //request delete doubledate
        [self.apiController requestDeleteDoubleDate:doubleDate];
        
        //release object
        [doubleDate release];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    contentOffset_ = scrollView.contentOffset;
}

- (void)applyScrollViewContentOffsetChange:(UIScrollView *)scrollView
{
    CGFloat dh = scrollView.contentOffset.y - contentOffset_.y;
#warning Michael customize drag distance here
    CGFloat dragDistance = 50;
    if (self.isDatesViewFullScreen)
    {
        if (dh < -dragDistance)
            self.isDatesViewFullScreen = NO;
    }
    else
    {
        //check if we don't have enough frame for table
        if (self.tableView.frame.size.height < [doubleDatesMine_ count] * [DDDoubleDateTableViewCell height])
        {
            if (dh > dragDistance)
                self.isDatesViewFullScreen = YES;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.isDragging)
        [self applyScrollViewContentOffsetChange:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self applyScrollViewContentOffsetChange:scrollView];
}

#pragma mark -
#pragma mark api

- (void)getMyDoubleDatesSucceed:(NSArray*)doubleDates
{
    //save doubledates
    [doubleDatesMine_ release];
    doubleDatesMine_ = [[NSMutableArray arrayWithArray:doubleDates] retain];
    
    //inform about completion
    [self reinitDates];
}

- (void)getMyDoubleDatesDidFailedWithError:(NSError*)error
{
    //save friends
    [doubleDatesMine_ release];
    doubleDatesMine_ = [[NSMutableArray alloc] init];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
    
    //inform about completion
    [self reinitDates];
}

- (void)requestDeleteDoubleDateSucceed
{
}

- (void)requestDeleteDoubleDateDidFailedWithError:(NSError*)error
{
    //refresh
    [self.apiController getMyDoubleDates];
}

- (void)getDoubleDateSucceed:(DDDoubleDate*)doubleDate
{
    //hide hud
    [self hideHud:YES];
    
    //open view controller
    DDDoubleDateViewController *viewController = [[[DDDoubleDateViewController alloc] init] autorelease];
    viewController.doubleDate = doubleDate;
    viewController.backButtonTitle = self.navigationItem.title;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)getDoubleDateDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma mark animation

- (void)setIsDatesViewFullScreen:(BOOL)v
{
    if (isDatesViewFullScreen != v)
    {
        isDatesViewFullScreen = v;
#warning Michael customize animation parameters here
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.viewBottom.frame = CGRectMake(self.viewBottom.frame.origin.x,
                                               self.isDatesViewFullScreen ? 0 : [self verticalOffsetForBottomView],
                                               self.viewBottom.frame.size.width,
                                               self.isDatesViewFullScreen ? self.view.bounds.size.height : self.view.bounds.size.height - [self verticalOffsetForBottomView]
                                               );

        } completion:^(BOOL finished) {
        }];
    }
}

@end
