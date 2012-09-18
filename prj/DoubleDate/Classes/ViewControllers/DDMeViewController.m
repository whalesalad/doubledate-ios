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

@interface DDMeViewController ()<UIWebViewDelegate>

@end

@implementation DDMeViewController

@synthesize user;
@synthesize labelTitle;
@synthesize imageViewPoster;
@synthesize imageViewMale;
@synthesize imageViewFemale;
@synthesize labelAge;
@synthesize labelLocation;
@synthesize textViewBio;

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
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"My Profile", nil);
    
    //add right button
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStyleDone target:self action:@selector(editTouched:)] autorelease];
    
    //set title
    labelTitle.text = [NSString stringWithFormat:@"%@ %@", [user.firstName capitalizedString], [user.lastName capitalizedString]];
    
    //set poster
    if (user.photo.downloadUrl)
        [imageViewPoster reloadFromUrl:[NSURL URLWithString:user.photo.downloadUrl]];
    
    //apply gender
    imageViewFemale.hidden = ![user.gender isEqualToString:DDUserGenderFemale];
    imageViewMale.hidden = ![user.gender isEqualToString:DDUserGenderMale];
    
    //set biography
    textViewBio.text = user.bio;
    
    //set age
    labelAge.text = [[user age] stringValue];
    
    //set location
    labelLocation.text = [[user location] name];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [labelTitle release], labelTitle = nil;
    [imageViewPoster release], imageViewPoster = nil;
    [imageViewMale release], imageViewMale = nil;
    [imageViewFemale release], imageViewFemale = nil;
    [textViewBio release], textViewBio = nil;
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
    [imageViewMale release];
    [imageViewFemale release];
    [textViewBio release];
    [super dealloc];
}

#pragma mark -
#pragma comment other

- (void)editTouched:(id)sender
{
}

@end
