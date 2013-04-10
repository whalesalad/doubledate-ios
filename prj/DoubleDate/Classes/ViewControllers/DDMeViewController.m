//
//  DDMeViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDMeViewController.h"
#import "DDUser.h"
#import "DDImage.h"
#import "DDImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "DDPlacemark.h"
#import "DDInterest.h"
#import "DDAuthenticationController.h"
#import "DDBarButtonItem.h"
#import "DDWingsViewController.h"
#import "DDTools.h"
#import "UIView+Interests.h"
#import "DDWingTableViewCell.h"
#import "DDAppDelegate+Navigation.h"
#import "DDEditProfileViewController.h"
#import "DDObjectsController.h"
#import "DDCoinsBar.h"
#import "DDPurchaseViewController.h"
#import "DDAppDelegate+Purchase.h"
#import "DDCreateDoubleDateViewController.h"
#import "DDShortUser.h"
#import "DDDialogAlertView.h"
#import "DDDialog.h"
#import "DDAppDelegate+NavigationMenu.h"
#import "DDImageEditDialogView.h"
#import "SBJson.h"
#import "UIImage+DD.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kTagActionSheetEdit 1
#define kTagActionSheetChangePhoto 2
#define kTagLoadingSpinner 3

@interface DDMeViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DDImageEditDialogViewDelegate>

- (void)setMeNavigationItemTitle;
- (void)setAvatarShown:(BOOL)shown;
- (void)updateAvatarWithImage:(UIImage*)image;

@property(nonatomic, retain) CAGradientLayer *textViewBioGradient;
@property(nonatomic, retain) CALayer *bottomBorder;
@property(nonatomic, retain) DDImageEditDialogView *imageEditView;

@end

@implementation DDMeViewController

@synthesize user;
@synthesize scrollView;
@synthesize labelTitle;
@synthesize imageViewPoster;
@synthesize labelLocation;
@synthesize textViewBio;
@synthesize textViewBioWrapper;
@synthesize viewInterests;
@synthesize labelInterests;
@synthesize interestsWrapper;
@synthesize imageViewGender;
@synthesize imageViewBioBackground;
@synthesize coinBarContainer;
@synthesize textViewBioGradient;
@synthesize bottomBorder;
@synthesize doubleDateBarContainer;
@synthesize buttonDoubleDate;
@synthesize imageEditView;

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

- (DDCoinsBar*)coinBar
{
    for (DDCoinsBar *v in [self.coinBarContainer subviews])
    {
        if ([v isKindOfClass:[DDCoinsBar class]])
            return v;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //localize
    labelInterests.text = NSLocalizedString(@"ICE BREAKERS", nil);
    [buttonDoubleDate setTitle:[NSString stringWithFormat:NSLocalizedString(@"DoubleDate with %@", @"Doubledate button on wing's profile page"), self.user.firstName] forState:UIControlStateNormal];
    
    //add coin bar
    [self.coinBarContainer addSubview:[[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DDCoinsBar class]) owner:self options:nil] objectAtIndex:0]];
    
    self.coinBarContainer.layer.shadowOffset = CGSizeMake(0, -1);
    self.coinBarContainer.layer.shadowOpacity = 0.5f;
    self.coinBarContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    
    [self.buttonDoubleDate setBackgroundImage:[DDTools resizableImageFromImage:[self.buttonDoubleDate backgroundImageForState:UIControlStateNormal]] forState:UIControlStateNormal];
    
    //add handler
    [[self coinBar] addTarget:self action:@selector(moreCoinsTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    //add handler
    [self.buttonDoubleDate addTarget:self action:@selector(doubleDateTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    //apply mask
    [self.imageViewPoster applyMask:[UIImage imageNamed:@"bg-me-photo-mask.png"]];
    
    //we can edit only yourself
    if ([[[DDAuthenticationController currentUser] userId] intValue] == [user.userId intValue])
    {
        //set title
        [self setMeNavigationItemTitle];
        
        //add right button
        self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"button-gear.png"] target:self action:@selector(editTouched:)];
    }
    else
    {
        //set title
        self.navigationItem.title = [user.firstName capitalizedString];
        
        // Temporarily hide the coinbar for users that are not you,
        // until bubble is integrated for wings
        self.coinBarContainer.hidden = true;
        self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height+self.coinBarContainer.frame.size.height);
        
        //show doubledate bar
        self.doubleDateBarContainer.hidden = NO;
        
        //update scroll bar
        self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height-self.doubleDateBarContainer.frame.size.height);
    }
    
    //set title
    labelTitle.text = [DDWingTableViewCell titleForUser:user];
    labelTitle.frame = CGRectMake(labelTitle.frame.origin.x, labelTitle.frame.origin.y, [labelTitle sizeThatFits:labelTitle.bounds.size].width, labelTitle.frame.size.height);
    
    //set gender
    if ([[user gender] isEqualToString:DDUserGenderFemale])
        imageViewGender.image = [UIImage imageNamed:@"icon-gender-female.png"];
    else
        imageViewGender.image = [UIImage imageNamed:@"icon-gender-male.png"];
    imageViewGender.frame = CGRectMake(labelTitle.frame.origin.x+labelTitle.frame.size.width+4, labelTitle.center.y-imageViewGender.image.size.height/2, imageViewGender.image.size.width, imageViewGender.image.size.height);
    
    //set poster
    if (user.photo.mediumUrl)
        [imageViewPoster reloadFromUrl:[NSURL URLWithString:user.photo.mediumUrl]];
    
    //reinit bio
    [self reinitBio];
    
    //reinit location
    [self reinitLocation];
    
    //reinit coins
    [self reinitCoins];
    
    //make background clear
    labelTitle.backgroundColor = [UIColor clearColor];
    imageViewPoster.backgroundColor = [UIColor clearColor];
    labelLocation.backgroundColor = [UIColor clearColor];
    viewInterests.backgroundColor = [UIColor clearColor];
    labelInterests.backgroundColor = [UIColor clearColor];
    interestsWrapper.backgroundColor = [UIColor clearColor];
    imageViewGender.backgroundColor = [UIColor clearColor];
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
    [super viewWillAppear:animated];
    [self reinitBio];
    [self reinitInterests];
    [self reinitLocation];
    [self reinitCoins];
}

- (void)reinitCoins
{
    [[self coinBar] setValue:[[user totalCoins] intValue]];
}

- (void)reinitInterests
{
    // space between textViewBio and interestsWrapper
    CGFloat textInterestSpacing = 12.0f;
    
    // resize interest wrapper view
    CGRect interestsWrapperFrame = self.interestsWrapper.frame;
    interestsWrapperFrame.origin.y = textViewBioWrapper.frame.size.height + textViewBioWrapper.frame.origin.y + textInterestSpacing;
    self.interestsWrapper.frame = interestsWrapperFrame;
    
    //save old frame
    CGRect oldInterestsFrame = viewInterests.frame;
    
    //apply interests
    CGFloat newInterestsHeight = [viewInterests applyInterestsForUser:self.user
                                                          bubbleImage:[UIImage imageNamed:@"bg-me-interest.png"]
                                                   matchedBubbleImage:[UIImage imageNamed:@"bg-me-interest.png"]
                                                custmomizationHandler:^(UILabel *bubbleLabel) {
                                                    DD_F_INTEREST_TEXT(bubbleLabel);
                                                    bubbleLabel.textColor = [UIColor whiteColor];
                                                    bubbleLabel.backgroundColor = [UIColor clearColor];
                                                }];
    
    //change frame
    viewInterests.frame = CGRectMake(oldInterestsFrame.origin.x, oldInterestsFrame.origin.y, oldInterestsFrame.size.width, newInterestsHeight);
    
    //apply needed content size
    self.scrollView.contentSize = CGSizeMake(320, viewInterests.frame.origin.y+interestsWrapper.frame.origin.y+viewInterests.frame.size.height);
}

- (void)reinitBio
{
    //set biography
    textViewBio.text = user.bio;
    
    // watch for text view change
    textViewBioWrapper.frame = CGRectMake(0, 0, textViewBioWrapper.frame.size.width, self.imageViewPoster.frame.size.height + textViewBio.contentSize.height + 10);
    
    //remove old one
    [self.textViewBioGradient removeFromSuperlayer];
    self.textViewBioGradient = nil;
    
    // Create inner gradient for bio
    self.textViewBioGradient = [CAGradientLayer layer];
    self.textViewBioGradient.frame = textViewBioWrapper.bounds;
    self.textViewBioGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor],
                                       (id)[[UIColor colorWithWhite:1.0f alpha:0.1f] CGColor], nil];
    
    // Add the gradient to the back of the text view
    [textViewBioWrapper.layer insertSublayer:self.textViewBioGradient atIndex:0];
    
    //remove old one
    [self.bottomBorder removeFromSuperlayer];
    self.bottomBorder = nil;
    
    // Create transparent white line to add below bio view.
    self.bottomBorder = [CALayer layer];
    self.bottomBorder.frame = CGRectMake(0.0f, textViewBioWrapper.frame.origin.y + textViewBioWrapper.frame.size.height, 320, 1.0f);
    self.bottomBorder.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.03f].CGColor;
    
    // Add the border to the scrollview
    [scrollView.layer addSublayer:self.bottomBorder];
}

- (void)reinitLocation
{
    //set location
    labelLocation.text = [[user location] name];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [user release];
    [scrollView release];
    [labelTitle release];
    [imageViewPoster release];
    [labelLocation release];
    [textViewBio release];
    [textViewBioWrapper release];
    [viewInterests release];
    [labelInterests release];
    [interestsWrapper release];
    [imageViewGender release];
    [imageViewBioBackground release];
    [coinBarContainer release];
    [doubleDateBarContainer release];
    [buttonDoubleDate release];
    [textViewBioGradient release];
    [bottomBorder release];
    [imageEditView release];
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

- (void)backTouched:(id)sender
{
    if ([[[DDAuthenticationController currentUser] userId] intValue] == [user.userId intValue])
        [self.tabBarController.navigationController popViewControllerAnimated:YES];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)moreCoinsTouched:(id)sender
{
    [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] presentPurchaseScreen];
}

- (void)doubleDateTouched:(id)sender
{
    //fill user data
    DDShortUser *wing = [[[DDShortUser alloc] init] autorelease];
    wing.identifier = self.user.userId;
    wing.photo = self.user.photo;
    wing.fullName = [NSString stringWithFormat:@"%@ %@", self.user.firstName, self.user.lastName];
    
    //create view controller
    DDCreateDoubleDateViewController *viewController = [[[DDCreateDoubleDateViewController alloc] init] autorelease];
    viewController.wing = wing;
    [self.navigationController presentViewController:[[[UINavigationController alloc] initWithRootViewController:viewController] autorelease] animated:YES completion:^{
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
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Choose Existing Photo", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Take New Photo", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Pull Facebook Photo", nil)];
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
    self.navigationItem.title = [NSString localizedStringWithFormat:@"Hi %@!", user.firstName];
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
    if ([[notification object] isKindOfClass:[DDUser class]])
    {
        DDUser *userToUpdate = (DDUser*)[notification object];
        if ([[userToUpdate userId] intValue] == [self.user.userId intValue])
            self.user = userToUpdate;
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
        [imageViewPoster reloadFromUrl:[NSURL URLWithString:photo.mediumUrl]];
        
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
    UIImage *cutImage = [DDTools cutImageFromImage:image withRect:rect];
    
    //update poster
    self.imageViewPoster.image = cutImage;
    
    //update photo
    if (sender.uiImage)
        [self.apiController updatePhotoForMe:image cropRect:rect];
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

@end
