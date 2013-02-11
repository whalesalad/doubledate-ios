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

#define kTagActionSheetEdit 1

@interface DDMeViewController () <UIActionSheetDelegate>

@end

@implementation DDMeViewController

@synthesize user;
@synthesize scrollView;
@synthesize labelTitle;
@synthesize imageViewPoster;
@synthesize labelLocation;
@synthesize textViewBio;
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
    CGRect textViewBioFrame = textViewBio.frame;
    textViewBioFrame.size.height = textViewBio.contentSize.height + 10;
    textViewBio.frame = textViewBioFrame;
    
    // Create transparent white line to add below bio view.
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, textViewBio.frame.origin.y + textViewBio.frame.size.height, 320, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.03f].CGColor;
    
    // Add the border to the scrollview
    [scrollView.layer addSublayer:bottomBorder];
    
    // Create inner gradient for bio
    CAGradientLayer *textViewBioGradient = [CAGradientLayer layer];
    textViewBioGradient.frame = textViewBio.bounds;
    textViewBioGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor],
                                                           (id)[[UIColor colorWithWhite:1.0f alpha:0.1f] CGColor], nil];
    
    // Add the gradient to the back of the text view
    [textViewBio.layer insertSublayer:textViewBioGradient atIndex:0];
    
    
    // change position
//    self.labelInterests.frame = CGRectMake(labelInterests.frame.origin.x, labelInterests.frame.origin.y+dh, labelInterests.frame.size.width, labelInterests.frame.size.height);
    
//    self.labelInterests.hidden = [self.user.interests count] == 0;
    
//    self.viewInterests.frame = CGRectMake(viewInterests.frame.origin.x, viewInterests.frame.origin.y+dh, viewInterests.frame.size.width, viewInterests.frame.size.height);
    
//    self.viewInterests.hidden = self.labelInterests.hidden;
    
    // space between textViewBio and interestsWrapper
    CGFloat textInterestSpacing = 12.0f;
    
    // resize interest wrapper view
    CGRect interestsWrapperFrame = self.interestsWrapper.frame;
    interestsWrapperFrame.origin.y = textViewBio.frame.size.height + textViewBio.frame.origin.y + textInterestSpacing;
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
    self.scrollView.contentSize = CGSizeMake(320, viewInterests.frame.origin.y+viewInterests.frame.size.height);
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
    
}

- (void)logoutTouched
{
    [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] logout];
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
}

@end
