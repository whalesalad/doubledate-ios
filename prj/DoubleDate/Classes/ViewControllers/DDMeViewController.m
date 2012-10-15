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
#import "DDTagsView.h"
#import "DDInterest.h"
#import "DDAuthenticationController.h"

@interface DDMeViewController ()

@end

@implementation DDMeViewController

@synthesize user;
@synthesize labelTitle;
@synthesize imageViewPoster;
@synthesize imageViewOverlay;
//@synthesize imageViewMale;
//@synthesize imageViewFemale;
@synthesize labelAge;
@synthesize labelLocation;
@synthesize textViewBio;
@synthesize tagsViewInterests;
@synthesize imageViewLocation;

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
    
    //we can edit only yourself
    if ([[DDAuthenticationController userId] isEqualToString:[user.userId stringValue]])
    {
        //set title
        self.navigationItem.title = NSLocalizedString(@"My Profile", nil);
        
        //add right button
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStyleDone target:self action:@selector(editTouched:)] autorelease];
    }
    else
    {
        //set title
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", [user.firstName capitalizedString], [user.lastName capitalizedString]];
    }
    
    //set title
    labelTitle.text = [NSString stringWithFormat:@"%@ %@", [user.firstName capitalizedString], [user.lastName capitalizedString]];
    
    labelTitle.layer.shadowOpacity = 0.8;
    labelTitle.layer.shadowRadius = 1.0;
    labelTitle.layer.shadowColor = [UIColor blackColor].CGColor;
    labelTitle.layer.shadowOffset = CGSizeMake(0.0, 2.0);
    
    //set poster
    if (user.photo.downloadUrl)
        [imageViewPoster reloadFromUrl:[NSURL URLWithString:user.photo.downloadUrl]];
    else
        imageViewOverlay.hidden = YES;
    
    //apply gender
//    imageViewFemale.hidden = ![user.gender isEqualToString:DDUserGenderFemale];
//    imageViewMale.hidden = ![user.gender isEqualToString:DDUserGenderMale];
    
    //set biography
    textViewBio.text = user.bio;
    
    textViewBio.layer.shadowOpacity = 1.0;
    textViewBio.layer.shadowRadius = 0.0;
    textViewBio.layer.shadowColor = [UIColor whiteColor].CGColor;
    textViewBio.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    
    // Set age/gender text
    NSMutableString *ageText = [NSMutableString string];
    
    if (user.age) {
        [ageText appendFormat:@"%d", [user.age intValue]];
        if ([user.gender isEqualToString:DDUserGenderFemale]) {
            [ageText appendString:@"F"];
        } else if ([user.gender isEqualToString:DDUserGenderMale]) {
            [ageText appendString:@"M"];
        }
    }
    
    [labelAge setText:ageText];
    
    labelAge.layer.shadowOpacity = 0.8;
    labelAge.layer.shadowRadius = 1.0;
    labelAge.layer.shadowColor = [UIColor blackColor].CGColor;
    labelAge.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    
    //set location
    labelLocation.text = [[user location] name];
    
    labelLocation.layer.shadowOpacity = 0.8;
    labelLocation.layer.shadowRadius = 1.0;
    labelLocation.layer.shadowColor = [UIColor blackColor].CGColor;
    labelLocation.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    
    //hide or show
    imageViewLocation.hidden = [labelLocation.text length] > 0;
    
    //set interests
    NSMutableArray *tags = [NSMutableArray array];
    for (DDInterest *interest in [user interests])
        [tags addObject:interest.name];
    tagsViewInterests.tags = tags;
    
    //watch for text view change
    [textViewBio sizeToFit];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tagsViewInterests customize];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [labelTitle release], labelTitle = nil;
    [imageViewPoster release], imageViewPoster = nil;
    [imageViewOverlay release], imageViewOverlay = nil;
//    [imageViewMale release], imageViewMale = nil;
//    [imageViewFemale release], imageViewFemale = nil;
    [textViewBio release], textViewBio = nil;
    [tagsViewInterests release], tagsViewInterests = nil;
    [imageViewLocation release], imageViewLocation = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [user release];
    [labelTitle release];
    [imageViewPoster release];
    [imageViewOverlay release];
//    [imageViewMale release];
//    [imageViewFemale release];
    [textViewBio release];
    [tagsViewInterests release];
    [imageViewLocation release];
    [super dealloc];
}

#pragma mark -
#pragma comment other

- (void)editTouched:(id)sender
{
}

@end
