//
//  DDCreateDoubleDateViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDCreateDoubleDateViewController.h"
#import "DDShortUser.h"
#import "DDWingsViewController.h"
#import "DDImageView.h"
#import "DDPlacemark.h"
#import "DDLocationChooserViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DDTextView.h"
#import "DDDoubleDate.h"
#import "DDDoubleDatesViewController.h"

@interface DDCreateDoubleDateViewController () <DDWingsViewControllerDelegate, DDLocationPickerViewControllerDelegate, DDLocationControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property(nonatomic, retain) DDShortUser *wing;
@property(nonatomic, retain) DDPlacemark *location;

@end

@implementation DDCreateDoubleDateViewController

@synthesize wing;
@synthesize location;
@synthesize buttonWing;
@synthesize buttonLocation;
@synthesize textViewDetails;
@synthesize textFieldTitle;
@synthesize segmentedControlDay;
@synthesize segmentedControlTime;
@synthesize user;
@synthesize doubleDatesViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        locationController_ = [[DDLocationController alloc] init];
        locationController_.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"New DoubleDate", nil);
    
    //add left button
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(backTouched:)] autorelease];
    
    //set right button
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Post", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(postTouched:)] autorelease];
    
    //set next button
    self.textFieldTitle.returnKeyType = UIReturnKeyNext;
    
    //set text field observer
    
    //set text vide delegte
    self.textViewDetails.textView.delegate = self;
    
    //apply text
    self.buttonWing.placeholder = NSLocalizedString(@"Choose a wing...", nil);
    
    //apply text
    self.buttonLocation.placeholder = NSLocalizedString(@"Choose a location...", nil);
    
    //apply wing
    self.wing = self.wing;
    
    //apply location
    self.location = self.location;
    
    //force location update
    [locationController_ forceSearchPlacemarks];
    
    //update navigation bar
    [self updateNavigationBar];
}

- (void)viewDidUnload
{
    [buttonWing release], buttonWing = nil;
    [buttonLocation release], buttonLocation = nil;
    [textViewDetails release], textViewDetails = nil;
    [textFieldTitle release], textFieldTitle = nil;
    [segmentedControlDay release], segmentedControlDay = nil;
    [segmentedControlTime release], segmentedControlTime = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    locationController_.delegate = nil;
    [locationController_ release];
    [buttonWing release];
    [buttonLocation release];
    [textViewDetails release];
    [textFieldTitle release];
    [segmentedControlDay release];
    [segmentedControlTime release];
    [wing release];
    [location release];
    [user release];
    [doubleDatesViewController release];
    [super dealloc];
}

#pragma mark -
#pragma comment other

- (IBAction)wingTouched:(id)sender
{
    DDWingsViewController *wingsViewController = [[[DDWingsViewController alloc] init] autorelease];
    wingsViewController.delegate = self;
    wingsViewController.isSelectingMode = YES;
    [self.navigationController pushViewController:wingsViewController animated:YES];
}

- (IBAction)locationTouched:(id)sender
{
    DDLocationChooserViewController *locationChooserViewController = [[[DDLocationChooserViewController alloc] init] autorelease];
    locationChooserViewController.delegate = self;
    locationChooserViewController.location = locationController_.location;
    [self.navigationController pushViewController:locationChooserViewController animated:YES];
}

- (IBAction)freeAreaTouched:(id)sender
{
    if ([self.textFieldTitle isFirstResponder])
        [self.textFieldTitle resignFirstResponder];
    if ([self.textViewDetails.textView isFirstResponder])
        [self.textViewDetails.textView resignFirstResponder];
}

- (void)setWing:(DDShortUser *)v
{
    //update value
    if (wing != v)
    {
        [wing release];
        wing = [v retain];
    }
    
    //apply blank image by default
    self.buttonWing.normalIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank-wingman-icon.png"]] autorelease];
    
    //apply wing
    if (wing)
    {
        //load image
        if ([[wing photo] downloadUrl])
        {
            DDImageView *imageView = [[[DDImageView alloc] init] autorelease];
            imageView.frame = CGRectMake(0, 0, 34, 34);
            imageView.layer.cornerRadius = 17;
            imageView.layer.masksToBounds = YES;
            [imageView reloadFromUrl:[NSURL URLWithString:[[wing photo] downloadUrl]]];
            self.buttonWing.normalIcon = imageView;
        }
        
        //apply text
        self.buttonWing.text = [wing fullName];
    }
    
    //update navigation button
    [self updateNavigationBar];
}

- (void)setLocation:(DDPlacemark *)v
{
    //update value
    if (location != v)
    {
        [location release];
        location = [v retain];
    }
    
    //apply blank image by default
    self.buttonLocation.normalIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location-icon-blank.png"]] autorelease];
    
    //set text by default
    self.buttonLocation.text = nil;
    
    //unset right view by default
    self.buttonLocation.rightView = nil;
    
    //apply location
    if (location)
    {
        //apply image
        self.buttonLocation.normalIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location-icon-selected.png"]] autorelease];
        
        //set location text
        self.buttonLocation.text = [location name];
        
        //set close button
        UIImage *closeImage = [UIImage imageNamed:@"location-reset-button.png"];
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(0, 0, closeImage.size.width, closeImage.size.height);
        [closeButton addTarget:self action:@selector(resetLocationTouched:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setBackgroundImage:closeImage forState:UIControlStateNormal];
        self.buttonLocation.rightView = closeButton;
    }
    
    //update navigation button
    [self updateNavigationBar];
}

- (void)resetLocationTouched:(id)sender
{
    self.location = nil;
}

- (void)backTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)postTouched:(id)sender
{
    //set up double date
    DDDoubleDate *doubleDate = [[[DDDoubleDate alloc] init] autorelease];
    doubleDate.title = self.textFieldTitle.text;
    doubleDate.details = self.textViewDetails.text;
    doubleDate.wingId = self.wing.identifier;
    doubleDate.userId = self.user.userId;
    doubleDate.locationId = self.location.identifier;
    switch (self.segmentedControlDay.selectedSegmentIndex) {
        case 0:
            doubleDate.dayPref = DDDoubleDateDayPrefWeekday;
            break;
        case 1:
            doubleDate.dayPref = DDDoubleDateDayPrefWeekend;
            break;
        default:
            break;
    }
    switch (self.segmentedControlTime.selectedSegmentIndex) {
        case 0:
            doubleDate.timePref = DDDoubleDateTimePrefDaytime;
            break;
        case 1:
            doubleDate.timePref = DDDoubleDateTimePrefNighttime;
            break;
        default:
            break;
    }
    
    //show hud
    [self showHudWithText:NSLocalizedString(@"Creating", nil) animated:YES];
    
    //request friends
    [self.apiController createDoubleDate:doubleDate];
}

- (void)updateNavigationBar
{
    //update right button
    BOOL rightButtonEnabled = YES;
    if ([self.textFieldTitle.text length] == 0)
        rightButtonEnabled = NO;
    if ([self.textViewDetails.text length] == 0)
        rightButtonEnabled = NO;
    if (!self.location)
        rightButtonEnabled = NO;
    if (!self.wing)
        rightButtonEnabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = rightButtonEnabled;
}

#pragma mark -
#pragma comment DDWingsViewControllerDelegate

- (void)wingsViewController:(DDWingsViewController*)viewController didSelectUser:(DDShortUser*)aUser
{
    [self setWing:aUser];
    [viewController.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma comment DDLocationPickerViewControllerDelegate

- (void)locationPickerViewControllerDidFoundPlacemarks:(NSArray*)placemarks
{
    [self setLocation:[placemarks objectAtIndex:0]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)locationPickerViewControllerDidCancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma comment DDLocationControllerDlegate

- (void)locationManagerDidFoundLocation:(CLLocation*)location
{
    
}

- (void)locationManagerDidFailedWithError:(NSError*)error
{
    //remove loading
    self.buttonLocation.normalIcon = nil;
    self.buttonLocation.selectedIcon = nil;
    
    //updat text
    self.buttonLocation.placeholder = NSLocalizedString(@"Failed to find location", nil);
    
    //disable button
    self.buttonLocation.enabled = NO;
}

- (BOOL)locationManagerShouldGeoDecodeLocation:(CLLocation*)location
{
    return NO;
}

- (void)locationManagerDidFoundPlacemarks:(NSArray*)placemarks
{
}

#pragma mark -
#pragma comment API

- (void)createDoubleDateSucceed:(DDDoubleDate*)doubleDate
{
    //hide hud
    [self hideHud:YES];
    
    //add doubledate
    [self.doubleDatesViewController setDoubleDateToAdd:doubleDate];
    
    //show succeed message
    NSString *message = NSLocalizedString(@"Done", nil);
    
    //show completed hud
    [self showCompletedHudWithText:message];
    
    //go back
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createDoubleDateDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma comment UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textViewDetails.textView becomeFirstResponder];
    return YES;
}

- (void)textFieldTextDidChange:(NSNotification*)notification
{
    if ([notification object] == self.textFieldTitle)
        [self updateNavigationBar];
}

#pragma mark -
#pragma comment UITextVideDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateNavigationBar];
}

@end
