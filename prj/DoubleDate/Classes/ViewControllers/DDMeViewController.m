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

@interface DDMeViewController ()

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
@synthesize imageViewGender;
@synthesize labelCoinsTitle;
@synthesize labelCoinsValue;
@synthesize labelKarmaTitle;
@synthesize labelKarmaValue;
@synthesize imageViewBioBackground;

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
    if ([[DDAuthenticationController userId] isEqualToString:[user.userId stringValue]])
    {
        //set title
        self.navigationItem.title = [NSString localizedStringWithFormat:@"Hi %@!", user.firstName];
        
        //add right button
        self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Edit", nil) target:self action:@selector(editTouched:)];
        
        //remove left button
        self.navigationItem.leftBarButtonItem = nil;
    }
    else
    {
        //set title
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", [user.firstName capitalizedString], [user.lastName capitalizedString]];
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
    
    //set karma and coins
    self.labelCoinsValue.text = [NSString stringWithFormat:@"%d", [[user totalCoins] intValue]];
    self.labelKarmaValue.text = [NSString stringWithFormat:@"%d", [[user totalKarma] intValue]];
    
    //watch for text view change
    CGSize textViewBioSize = textViewBio.frame.size;
    CGSize newTextViewBioSize = [textViewBio sizeThatFits:textViewBio.bounds.size];
    textViewBio.frame = CGRectMake(textViewBio.frame.origin.x, textViewBio.frame.origin.y, newTextViewBioSize.width, MAX(newTextViewBioSize.height, 80));
    CGFloat dh = textViewBio.frame.size.height - textViewBioSize.height;
    
    //stick bio background image
    imageViewBioBackground.frame = CGRectMake(imageViewBioBackground.frame.origin.x, textViewBio.frame.origin.y+textViewBio.frame.size.height-imageViewBioBackground.frame.size.height, imageViewBioBackground.frame.size.width, imageViewBioBackground.frame.size.height);
    
    //change position
    self.labelInterests.frame = CGRectMake(labelInterests.frame.origin.x, labelInterests.frame.origin.y+dh, labelInterests.frame.size.width, labelInterests.frame.size.height);
    self.labelInterests.hidden = [self.user.interests count] == 0;
    self.viewInterests.frame = CGRectMake(viewInterests.frame.origin.x, viewInterests.frame.origin.y+dh, viewInterests.frame.size.width, viewInterests.frame.size.height);
    self.viewInterests.hidden = self.labelInterests.hidden;
    
    //make background clear
    labelTitle.backgroundColor = [UIColor clearColor];
    imageViewPoster.backgroundColor = [UIColor clearColor];
    labelLocation.backgroundColor = [UIColor clearColor];
    textViewBio.backgroundColor = [UIColor clearColor];
    viewInterests.backgroundColor = [UIColor clearColor];
    labelInterests.backgroundColor = [UIColor clearColor];
    imageViewGender.backgroundColor = [UIColor clearColor];
    labelCoinsTitle.backgroundColor = [UIColor clearColor];
    labelCoinsValue.backgroundColor = [UIColor clearColor];
    labelKarmaTitle.backgroundColor = [UIColor clearColor];
    labelKarmaValue.backgroundColor = [UIColor clearColor];
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
    CGFloat newInterestsHeight = [viewInterests applyInterests:self.user.interests withBubbleImage:[UIImage imageNamed:@"bg-me-interest.png"] custmomizationHandler:^(UILabel *bubbleLabel) {
        DD_F_ME_INTEREST_TEXT(bubbleLabel);
        bubbleLabel.textColor = [UIColor whiteColor];
        bubbleLabel.backgroundColor = [UIColor clearColor];
    }];
    
    //change frame
    viewInterests.frame = CGRectMake(oldInterestsFrame.origin.x, oldInterestsFrame.origin.y, oldInterestsFrame.size.width, newInterestsHeight);
    
    //apply needed content size
    self.scrollView.contentSize = CGSizeMake(320, viewInterests.frame.origin.y+viewInterests.frame.size.height);
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
    [imageViewGender release];
    [labelCoinsTitle release];
    [labelCoinsValue release];
    [labelKarmaTitle release];
    [labelKarmaValue release];
    [imageViewBioBackground release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (void)editTouched:(id)sender
{
}

- (void)backTouched:(id)sender
{
    if ([[DDAuthenticationController userId] isEqualToString:[user.userId stringValue]])
        [self.tabBarController.navigationController popViewControllerAnimated:YES];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

@end
