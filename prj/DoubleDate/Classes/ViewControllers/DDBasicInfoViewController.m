//
//  DDBasicInfoViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDBasicInfoViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DDAppDelegate.h"
#import <RestKit/RestKit.h>
#import <SBJson/SBJson.h>
#import "DDTools.h"
#import "DDFacebookController.h"
#import "DDUser.h"
#import "DDBioViewController.h"
#import "DDLocationPickerViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "DDPlacemark.h"
#import "DDImage.h"
#import "DDLocationController.h"

@interface DDBasicInfoViewController ()<UITextFieldDelegate, DDLocationPickerViewControllerDelegate, DDLocationControllerDelegate>

@end

@implementation DDBasicInfoViewController

@synthesize user;
@synthesize userLocation;
@synthesize textFieldName;
@synthesize textFieldSurname;
@synthesize textFieldBirth;
@synthesize segmentedControlMale;
@synthesize segmentedControlLike;
@synthesize segmentedControlSingle;
@synthesize labelLocation;
@synthesize imageViewPhoto;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        locationController_ = [[DDLocationController alloc] init];
        locationController_.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Basic Info", nil);
    
    //add right button
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil) style:UIBarButtonItemStyleDone target:self action:@selector(nextTouched:)] autorelease];
    
    //check for modal view
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleDone target:self action:@selector(cancelTouched:)] autorelease];
    
    //check if user exist
    if (user)
    {
        //set name
        textFieldName.text = [user firstName];
        
        //set surname
        textFieldSurname.text = [user lastName];
        
        //set birthday
        textFieldBirth.text = [user birthday];
        
        //set gender
        if ([[user gender] isEqualToString:DDUserGenderMale])
            segmentedControlMale.selectedSegmentIndex = 0;
        else if ([[user gender] isEqualToString:DDUserGenderFemale])
            segmentedControlMale.selectedSegmentIndex = 1;
        else
            segmentedControlMale.selectedSegmentIndex = -1;
        
        //save like
        if ([[user interestedIn] isEqualToString:DDUserInterestGuys])
            segmentedControlLike.selectedSegmentIndex = 0;
        else if ([[user interestedIn] isEqualToString:DDUserInterestGirls])
            segmentedControlLike.selectedSegmentIndex = 1;
        else if ([[user interestedIn] isEqualToString:DDUserInterestBoth])
            segmentedControlLike.selectedSegmentIndex = 2;
        else
            segmentedControlLike.selectedSegmentIndex = -1;

        //save single status
        if ([user.single boolValue])
            segmentedControlSingle.selectedSegmentIndex = 0;
        else
            segmentedControlSingle.selectedSegmentIndex = 1;
        
        //save location
        self.userLocation = user.location;
        
        //save photo
        if (user.photo.downloadUrl)
            [self.imageViewPhoto reloadFromUrl:[NSURL URLWithString:user.photo.downloadUrl]];
    }
    
    //set delegates
    textFieldName.delegate = self;
    textFieldSurname.delegate = self;
    textFieldBirth.delegate = self;
    
    //customize date picker
    UIDatePicker *datePicker = [[[UIDatePicker alloc] init] autorelease];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.maximumDate = [NSDate date];
    [datePicker addTarget:self action:@selector(birthdayChanged:) forControlEvents:UIControlEventValueChanged];
    textFieldBirth.inputView = datePicker;
    
    //force location update
    [locationController_ forceSearchPlacemarks];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [textFieldName release], textFieldName = nil;
    [textFieldSurname release], textFieldSurname = nil;
    [textFieldBirth release], textFieldBirth = nil;
    [segmentedControlMale release], segmentedControlMale = nil;
    [segmentedControlLike release], segmentedControlLike = nil;
    [segmentedControlSingle release], segmentedControlSingle = nil;
    [labelLocation release], labelLocation = nil;
    [imageViewPhoto release], imageViewPhoto = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

- (void)dealloc
{
    locationController_.delegate = nil;
    [locationController_ release];
    [user release];
    [userLocation release];
    [textFieldName release];
    [textFieldSurname release];
    [textFieldBirth release];
    [segmentedControlMale release];
    [segmentedControlLike release];
    [segmentedControlSingle release];
    [labelLocation release];
    [imageViewPhoto release];
    [super dealloc];
}

#pragma mark -
#pragma comment IB

- (IBAction)locationTouched:(id)sender
{
    DDLocationPickerViewController *viewController = [[[DDLocationPickerViewController alloc] init] autorelease];
    viewController.delegate = self;
    viewController.multiplyChoice = NO;
    [self.navigationController presentModalViewController:[[[UINavigationController alloc] initWithRootViewController:viewController] autorelease] animated:YES];
}

#pragma mark -
#pragma comment other

- (void)nextTouched:(id)sender
{
    //fill user data
    DDUser *newUser = [[user copy] autorelease];
    if (!newUser)
        newUser = [[[DDUser alloc] init] autorelease];
    newUser.firstName = textFieldName.text;
    newUser.lastName = textFieldSurname.text;
    newUser.birthday = textFieldBirth.text;
    if (segmentedControlSingle.selectedSegmentIndex == 0)
        newUser.single = [NSNumber numberWithBool:YES];
    else if (segmentedControlSingle.selectedSegmentIndex == 1)
        newUser.single = [NSNumber numberWithBool:NO];
    if (segmentedControlLike.selectedSegmentIndex == 0)
        newUser.interestedIn = DDUserInterestGuys;
    else if (segmentedControlLike.selectedSegmentIndex == 1)
        newUser.interestedIn = DDUserInterestGirls;
    else if (segmentedControlLike.selectedSegmentIndex == 2)
        newUser.interestedIn = DDUserInterestBoth;
    if (segmentedControlMale.selectedSegmentIndex == 0)
        newUser.gender = DDUserGenderMale;
    else if (segmentedControlMale.selectedSegmentIndex == 1)
        newUser.gender = DDUserGenderFemale;
    
    //save location
    if (self.userLocation)
        newUser.location = self.userLocation;
    
    //go next
    DDBioViewController *viewController = [[[DDBioViewController alloc] init] autorelease];
    viewController.user = newUser;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)cancelTouched:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)birthdayChanged:(UIDatePicker*)sender
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    self.textFieldBirth.text = [dateFormatter stringFromDate:sender.date];
}

#pragma mark -
#pragma comment UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.textFieldBirth)
        return NO;
    return YES;
}

#pragma mark -
#pragma comment DDLocationPickerViewControllerDelegate

- (void)locationPickerViewControllerDidFoundPlacemarks:(NSArray*)placemarks
{
    //check placemarks
    if ([placemarks count] == 1 && [[placemarks lastObject] isKindOfClass:[CLPlacemark class]])
    {
        //get placemark
        CLPlacemark *placemark = [placemarks lastObject];
        
        //convert to user location
        DDPlacemark *location = [[[DDPlacemark alloc] init] autorelease];
        location.name = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
        location.latitude = [NSString stringWithFormat:@"%f", placemark.location.coordinate.latitude];
        location.longitude = [NSString stringWithFormat:@"%f", placemark.location.coordinate.longitude];
        
        //update user location
        self.userLocation = location;
    }
    
    //dismiss view controller
    [self dismissModalViewControllerAnimated:YES];
}

- (void)locationPickerViewControllerDidCancel
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma comment DDLocationControllerDlegate

- (void)locationManagerDidFoundLocation:(CLLocation*)location
{
    
}

- (BOOL)locationManagerShouldGeoDecodeLocation:(CLLocation*)location
{
    return self.userLocation == nil;
}

- (void)locationManagerDidFoundPlacemarks:(NSArray*)placemarks
{
    if (!self.userLocation)
        self.userLocation = [placemarks objectAtIndex:0];
}

#pragma mark -
#pragma mark setter

- (void)setUserLocation:(DDPlacemark *)v
{
    //check the same value
    if (v != self.userLocation)
    {
        //init object
        [userLocation release];
        userLocation = [v retain];
        
        //update label
        labelLocation.text = v.name;
    }
}

@end
