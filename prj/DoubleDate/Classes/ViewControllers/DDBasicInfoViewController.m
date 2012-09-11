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
#import "DDUserLocation.h"

@interface DDBasicInfoViewController ()<UITextFieldDelegate, DDLocationPickerViewControllerDelegate>

@end

@implementation DDBasicInfoViewController

@synthesize facebookUser;
@synthesize userLocation;
@synthesize textFieldName;
@synthesize textFieldSurname;
@synthesize textFieldBirth;
@synthesize segmentedControlMale;
@synthesize segmentedControlLike;
@synthesize segmentedControlSingle;
@synthesize labelLocation;

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
    self.navigationItem.title = NSLocalizedString(@"Basic Info", nil);
    
    //add right button
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil) style:UIBarButtonItemStyleDone target:self action:@selector(nextTouched:)] autorelease];
    
    //check for modal view
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleDone target:self action:@selector(cancelTouched:)] autorelease];
    
    //check if user exist
    if (facebookUser)
    {
        //set name
        textFieldName.text = [facebookUser first_name];
        
        //set surname
        textFieldSurname.text = [facebookUser last_name];
        
        //set birthday
        if ([facebookUser birthday])
        {
            //get date
            NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
            [dateFormat setDateFormat:@"MM/dd/yyyy"];
            NSString *dateString = [facebookUser birthday];
            NSDate *date = [dateFormat dateFromString:dateString];

            //set date
            [dateFormat setDateFormat:@"yyyy-MM-dd"];
            textFieldBirth.text = [dateFormat stringFromDate:date];
        }
        
        //set gender
        if ([[facebookUser objectForKey:@"gender"] isEqualToString:@"male"])
            segmentedControlMale.selectedSegmentIndex = 0;
        else if ([[facebookUser objectForKey:@"gender"] isEqualToString:@"female"])
            segmentedControlMale.selectedSegmentIndex = 1;
        else
            segmentedControlMale.selectedSegmentIndex = -1;
        
        //save like
        segmentedControlLike.selectedSegmentIndex = -1;

        //save single status
        segmentedControlSingle.selectedSegmentIndex = -1;
    }
    
    //set delegates
    textFieldName.delegate = self;
    textFieldSurname.delegate = self;
    textFieldBirth.delegate = self;
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
    [facebookUser release];
    [userLocation release];
    [textFieldName release];
    [textFieldSurname release];
    [textFieldBirth release];
    [segmentedControlMale release];
    [segmentedControlLike release];
    [segmentedControlSingle release];
    [labelLocation release];
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
    DDUser *newUser = [[[DDUser alloc] init] autorelease];
    newUser.firstName = textFieldName.text;
    newUser.lastName = textFieldSurname.text;
    newUser.birthday = textFieldBirth.text;
    if (segmentedControlSingle.selectedSegmentIndex == 0)
        newUser.single = @"true";
    else if (segmentedControlSingle.selectedSegmentIndex == 1)
        newUser.single = @"false";
    if (segmentedControlLike.selectedSegmentIndex == 0)
        newUser.interestedIn = @"guys";
    else if (segmentedControlLike.selectedSegmentIndex == 1)
        newUser.interestedIn = @"girls";
    else if (segmentedControlLike.selectedSegmentIndex == 2)
        newUser.interestedIn = @"both";
    if (segmentedControlMale.selectedSegmentIndex == 0)
        newUser.gender = @"male";
    else if (segmentedControlMale.selectedSegmentIndex == 1)
        newUser.gender = @"female";
    
    //check for facebook
    if (facebookUser)
        newUser.facebookId = [facebookUser id];
    
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

#pragma mark -
#pragma comment UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
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
        DDUserLocation *location = [[[DDUserLocation alloc] init] autorelease];
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
#pragma mark setter

- (void)setUserLocation:(DDUserLocation *)v
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
