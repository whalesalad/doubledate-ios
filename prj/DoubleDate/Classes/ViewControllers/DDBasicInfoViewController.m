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
#import "SBJson.h"
#import "DDTools.h"
#import "DDFacebookController.h"
#import "DDUser.h"
#import "DDBioViewController.h"
#import "DDLocationChooserViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "DDPlacemark.h"
#import "DDImage.h"
#import "DDLocationController.h"
#import "DDBarButtonItem.h"
#import <QuartzCore/QuartzCore.h>

@interface DDBasicInfoViewController ()<UITextFieldDelegate, DDLocationPickerViewControllerDelegate, DDLocationControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

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
@synthesize buttonLocation;
@synthesize imageViewPhoto;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        locationController_ = [[DDLocationController alloc] init];
        locationController_.options = DDLocationSearchOptionsCities;
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
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Next", nil) target:self action:@selector(nextTouched:)];

    //add left button
    self.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Cancel", nil) target:self action:@selector(cancelTouched:)];
    
    //set placeholder
    self.buttonLocation.placeholder = NSLocalizedString(@"We're finding your location...", nil);
    
    //check if user exist
    if (user)
    {
        //set name
        textFieldName.text = [user firstName];
        
        //set surname
        textFieldSurname.text = [user lastName];
        
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
    
    //customize image view
    self.imageViewPhoto.contentMode = UIViewContentModeScaleAspectFill;
    self.imageViewPhoto.clipsToBounds = YES;
    [self.imageViewPhoto applyMask:[UIImage imageNamed:@"photo-mask.png"]];
    
    //set delegates
    textFieldName.returnKeyType = UIReturnKeyDone;
    textFieldName.delegate = self;
    textFieldSurname.returnKeyType = UIReturnKeyDone;
    textFieldSurname.delegate = self;
    textFieldBirth.delegate = self;
    
    //customize date picker
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *offsetComponents = [[[NSDateComponents alloc] init] autorelease];
    [offsetComponents setYear:-17];
    NSDate *maxDate = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
    [offsetComponents setYear:-80];
    NSDate *minDate = [gregorian dateByAddingComponents:offsetComponents toDate:maxDate options:0];
    UIDatePicker *datePicker = [[[UIDatePicker alloc] init] autorelease];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.maximumDate = maxDate;
    datePicker.minimumDate = minDate;
    [datePicker addTarget:self action:@selector(birthdayChanged:) forControlEvents:UIControlEventValueChanged];
    textFieldBirth.inputView = datePicker;
    
    //set current date of date picker
    if ([user birthday])
    {
        //update current date of date formatter
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        datePicker.date = [dateFormatter dateFromString:[user birthday]];
        
        //apply change
        [self birthdayChanged:datePicker];
    }
    else
        datePicker.date = [NSDate date];
    
    //update location
    self.userLocation = self.userLocation;
    
    //force location update
    [locationController_ forceSearchPlacemarks];
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
    [posterImage_ release];
    [user release];
    [userLocation release];
    [textFieldName release];
    [textFieldSurname release];
    [textFieldBirth release];
    [segmentedControlMale release];
    [segmentedControlLike release];
    [segmentedControlSingle release];
    [buttonLocation release];
    [imageViewPhoto release];
    [super dealloc];
}

#pragma mark -
#pragma mark IB

- (IBAction)locationTouched:(id)sender
{
    //check if location is exist
    if (self.userLocation)
    {
        //create view controller
        DDLocationChooserViewController *viewController = [[[DDLocationChooserViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        viewController.delegate = self;
        viewController.ddLocation = self.userLocation;
        viewController.options = DDLocationSearchOptionsCities;
        
        //create navigation controller
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (IBAction)posterTouched:(id)sender
{
    UIImagePickerController *imagePickerController = [[[UIImagePickerController alloc] init] autorelease];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    [self.navigationController presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

- (IBAction)freeAreaTouched:(id)sender
{
    if (self.textFieldName.isFirstResponder)
        [self.textFieldName resignFirstResponder];
    if (self.textFieldSurname.isFirstResponder)
        [self.textFieldSurname resignFirstResponder];
    if (self.textFieldBirth.isFirstResponder)
        [self.textFieldBirth resignFirstResponder];
}

#pragma mark -
#pragma mark other

- (void)nextTouched:(id)sender
{
    //fill user data
    DDUser *newUser = [[user copy] autorelease];
    if (!newUser)
        newUser = [[[DDUser alloc] init] autorelease];
    newUser.firstName = textFieldName.text;
    newUser.lastName = textFieldSurname.text;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    newUser.birthday = [dateFormatter stringFromDate:[(UIDatePicker*)textFieldBirth.inputView date]];
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
    
    //save poster
    if (posterImage_)
    {
        if (!newUser.photo)
            newUser.photo = [[[DDImage alloc] init] autorelease];
        newUser.photo.uploadImage = posterImage_;
    }
    
    //go next
    DDBioViewController *viewController = [[[DDBioViewController alloc] init] autorelease];
    viewController.user = newUser;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)cancelTouched:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)birthdayChanged:(UIDatePicker*)sender
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    self.textFieldBirth.text = [dateFormatter stringFromDate:sender.date];
}

#pragma mark -
#pragma mark UITextFieldDelegate

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
#pragma mark DDLocationPickerViewControllerDelegate

- (void)locationPickerViewControllerDidFoundPlacemarks:(NSArray*)placemarks
{
    //check one location
    if ([placemarks count] == 1)
    {
        if ([[placemarks lastObject] isKindOfClass:[CLPlacemark class]])
        {
            //get placemark
            CLPlacemark *placemark = [placemarks lastObject];
            
            //unset old location
            self.userLocation = nil;
            
            //try to decode location
            [locationController_ forceSearchPlacemarksForLocation:placemark.location];
        }
        else if ([[placemarks lastObject] isKindOfClass:[DDPlacemark class]])
        {
            //get placemark
            DDPlacemark *placemark = [placemarks lastObject];
            
            //unset old location
            self.userLocation = placemark;
            
            //pop view controller
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)locationPickerViewControllerDidCancel
{
}

#pragma mark -
#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    //save image
    [posterImage_ release];
    posterImage_ = [image retain];
    
    //set image view image
    self.imageViewPhoto.image = image;
    
    //dismiss modal view controller
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark -
#pragma mark UINavigationControllerDelegate


#pragma mark -
#pragma mark DDLocationControllerDlegate

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
    return self.userLocation == nil;
}

- (void)locationManagerDidFoundPlacemarks:(NSArray*)placemarks
{
    if (!self.userLocation)
    {
        if ([placemarks count] > 0)
            self.userLocation = [placemarks objectAtIndex:0];
    }
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
    }
    
    //update label
    if (v.name)
        self.buttonLocation.text = [NSString stringWithFormat:@"%@", v.name];
    else
        self.buttonLocation.text = nil;
        
    //update icon
    self.buttonLocation.normalIcon = [[[UIImageView alloc] initWithImage:self.buttonLocation.text?[UIImage imageNamed:@"location-marker"]:[UIImage animatedImageNamed:@"location-spinner" duration:0.3f]] autorelease];
}

@end
