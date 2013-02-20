//
//  DDMeViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
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
#import <MobileCoreServices/MobileCoreServices.h>

#define kTagActionSheetEdit 1
#define kTagActionSheetChangePhoto 2
#define kTagLoadingSpinner 3

@interface DDMeViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (void)setAvatarShown:(BOOL)shown;
- (void)updateAvatarWithImage:(UIImage*)image;

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
@synthesize labelCoinsContainer;
@synthesize buttonMoreCoins;
@synthesize labelCoins;
@synthesize imageViewCoins;
@synthesize coinBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageViewUpdateNotification:) name:DDImageViewUpdateNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //apply mask
    [self.imageViewPoster applyMask:[UIImage imageNamed:@"bg-me-photo-mask.png"]];
    
    //we can edit only yourself
    if ([[[DDAuthenticationController currentUser] userId] intValue] == [user.userId intValue])
    {
        //set title
        self.navigationItem.title = [NSString localizedStringWithFormat:@"Hi %@!", user.firstName];
        
        //add right button
        self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"button-gear.png"] target:self action:@selector(editTouched:)];
    }
    else
    {
        //set title
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", [user.firstName capitalizedString], [user.lastName capitalizedString]];
        
        // Temporarily hide the coinbar for users that are not you,
        // until bubble is integrated for wings
        self.coinBar.hidden = true;
        self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height+self.coinBar.frame.size.height);
        
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
    
    //set biography
    textViewBio.text = user.bio;
    
    //set location
    labelLocation.text = [[user location] name];
    
    //update more coins button
    [buttonMoreCoins setBackgroundImage:[DDTools resizableImageFromImage:[buttonMoreCoins backgroundImageForState:UIControlStateNormal]] forState:UIControlStateNormal];
    
    //update coins label
    labelCoins.text = [NSString stringWithFormat:@"%d", [[user totalCoins] intValue]];
        
    // watch for text view change
    CGRect textViewBioFrame = textViewBioWrapper.frame;
    textViewBioFrame.size.height = textViewBio.contentSize.height + 10;
    textViewBioWrapper.frame = textViewBioFrame;
    
    // Create transparent white line to add below bio view.
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, textViewBioWrapper.frame.origin.y + textViewBioWrapper.frame.size.height, 320, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.03f].CGColor;
    
    // Add the border to the scrollview
    [scrollView.layer addSublayer:bottomBorder];
    
    // Create inner gradient for bio
    CAGradientLayer *textViewBioGradient = [CAGradientLayer layer];
    textViewBioGradient.frame = textViewBioWrapper.bounds;
    textViewBioGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor],
                                                           (id)[[UIColor colorWithWhite:1.0f alpha:0.1f] CGColor], nil];
    
    // Add the gradient to the back of the text view
    [textViewBioWrapper.layer insertSublayer:textViewBioGradient atIndex:0];
    
    
    // change position
//    self.labelInterests.frame = CGRectMake(labelInterests.frame.origin.x, labelInterests.frame.origin.y+dh, labelInterests.frame.size.width, labelInterests.frame.size.height);
    
//    self.labelInterests.hidden = [self.user.interests count] == 0;
    
//    self.viewInterests.frame = CGRectMake(viewInterests.frame.origin.x, viewInterests.frame.origin.y+dh, viewInterests.frame.size.width, viewInterests.frame.size.height);
    
//    self.viewInterests.hidden = self.labelInterests.hidden;
    
    // space between textViewBio and interestsWrapper
    CGFloat textInterestSpacing = 12.0f;
    
    // resize interest wrapper view
    CGRect interestsWrapperFrame = self.interestsWrapper.frame;
    interestsWrapperFrame.origin.y = textViewBioWrapper.frame.size.height + textViewBioWrapper.frame.origin.y + textInterestSpacing;
    self.interestsWrapper.frame = interestsWrapperFrame;
    
    // Hide interests if there aren't any
    self.interestsWrapper.hidden = [self.user.interests count] == 0;
    
    
    
    //make background clear
    labelTitle.backgroundColor = [UIColor clearColor];
    imageViewPoster.backgroundColor = [UIColor clearColor];
    labelLocation.backgroundColor = [UIColor clearColor];
    viewInterests.backgroundColor = [UIColor clearColor];
    labelInterests.backgroundColor = [UIColor clearColor];
    interestsWrapper.backgroundColor = [UIColor clearColor];
    imageViewGender.backgroundColor = [UIColor clearColor];
    
    //align coins label
    [self alignCoinsLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reinitInterests];
}

- (void)reinitInterests
{
    //save old frame
    CGRect oldInterestsFrame = viewInterests.frame;
    
    //apply interests
    CGFloat newInterestsHeight = [viewInterests applyInterests:self.user.interests bubbleImage:[UIImage imageNamed:@"bg-me-interest.png"] matchedBubbleImage:[UIImage imageNamed:@"bg-me-interest.png"] custmomizationHandler:^(UILabel *bubbleLabel) {
        DD_F_INTEREST_TEXT(bubbleLabel);
        bubbleLabel.textColor = [UIColor whiteColor];
        bubbleLabel.backgroundColor = [UIColor clearColor];
    }];
    
    //change frame
    viewInterests.frame = CGRectMake(oldInterestsFrame.origin.x, oldInterestsFrame.origin.y, oldInterestsFrame.size.width, newInterestsHeight);
    
    //apply needed content size
    self.scrollView.contentSize = CGSizeMake(320, viewInterests.frame.origin.y+interestsWrapper.frame.origin.y+viewInterests.frame.size.height);
}

- (void)alignCoinsLabel
{
    //save distance between label and button
    CGFloat gap = (labelCoins.frame.origin.x - imageViewCoins.frame.origin.x - imageViewCoins.frame.size.width);
    
    //move label coins
    CGSize newLabelSize = CGSizeMake([labelCoins sizeThatFits:labelCoins.bounds.size].width, labelCoins.frame.size.height);
    
    //update center of the label
    labelCoins.frame = CGRectMake(0, labelCoins.frame.origin.y, newLabelSize.width, labelCoins.frame.size.height);
    labelCoins.center = CGPointMake(labelCoinsContainer.frame.size.width / 2 + (gap + imageViewCoins.frame.size.width) / 2, labelCoins.center.y);

    //update center of image view coins
    imageViewCoins.center = CGPointMake(labelCoins.frame.origin.x - gap - imageViewCoins.frame.size.width / 2, imageViewCoins.center.y);
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
    [buttonMoreCoins release];
    [labelCoins release];
    [imageViewCoins release];
    [coinBar release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (void)editTouched:(id)sender
{
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

- (IBAction)moreCoinsTouched:(id)sender
{
    
}

- (void)editProfileTouched
{
    
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
        imagePicker.allowsEditing = YES;
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
    [self loadImageFromSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
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
    updatePhotoRequest_ = [self.apiController updatePhotoForMeFromFacebook];
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
        [loadingView stopAnimating];
    
    //hide or show avatar
    [UIView animateWithDuration:0.5f animations:^{
        
        //update alpha
        self.imageViewPoster.alpha = shown?1:0;
    } completion:^(BOOL finished) {
        
        //start animating after fading
        if (!shown)
            [loadingView startAnimating];
    }];
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
                [self changePhotoChooseTouched];
                break;
            case 1:
                [self changePhotoCreateTouched];
                break;
            case 2:
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

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //check for image
    if (CFStringCompare((CFStringRef)[info objectForKey:UIImagePickerControllerMediaType], kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        //save image
        UIImage *image = nil;
        if ([info objectForKey:UIImagePickerControllerEditedImage])
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        else if ([info objectForKey:UIImagePickerControllerOriginalImage])
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //check image
        [self updateAvatarWithImage:image];
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
    //update url
    [imageViewPoster reloadFromUrl:[NSURL URLWithString:photo.mediumUrl]];
    
    //update object
    self.user.photo = photo;
}

- (void)updatePhotoForMeDidFailedWithError:(NSError*)error
{
    //show avatar
    [self setAvatarShown:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)updatePhotoForMeFromFacebookSucceed:(DDImage*)photo
{
    //update url
    [imageViewPoster reloadFromUrl:[NSURL URLWithString:photo.mediumUrl]];
    
    //update object
    self.user.photo = photo;
}

- (void)updatePhotoForMeFromFacebookDidFailedWithError:(NSError*)error
{
    //show avatar
    [self setAvatarShown:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
