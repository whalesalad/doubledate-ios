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
#import "DDLocation.h"
#import "DDLocationChooserViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DDTextView.h"
#import "DDDoubleDate.h"
#import "DDDoubleDatesViewController.h"
#import "DDCreateDoubleDateViewControllerChooseDate.h"
#import "DDBarButtonItem.h"

@interface DDCreateDoubleDateViewController () <DDWingsViewControllerDelegate, DDLocationPickerViewControllerDelegate, DDLocationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, DDCreateDoubleDateViewControllerChooseDateDelegate>

@property(nonatomic, retain) DDShortUser *wing;
@property(nonatomic, retain) DDLocation *location;

@property(nonatomic, retain) NSString *day;
@property(nonatomic, retain) NSString *time;

@end

@implementation DDCreateDoubleDateViewController

@synthesize wing;
@synthesize location;
@synthesize buttonWing;
@synthesize buttonLocation;
@synthesize textViewDetails;
@synthesize textFieldTitle;
@synthesize buttonDayTime;
@synthesize user;
@synthesize doubleDatesViewController;
@synthesize day;
@synthesize time;

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
    
    //set right button
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Post", nil) target:self action:@selector(postTouched:)];
    
    //set next button
    self.textFieldTitle.returnKeyType = UIReturnKeyNext;
        
    //set text vide delegte
    self.textViewDetails.textView.delegate = self;
    
    //apply text
    self.buttonWing.placeholder = NSLocalizedString(@"Choose a wing...", nil);
    
    //apply text
    self.buttonLocation.placeholder = NSLocalizedString(@"Choose a location...", nil);
    
    //apply daytime
    self.buttonDayTime.normalIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"create-dd-selected-daytime.png"]] autorelease];
    self.buttonDayTime.text = NSLocalizedString(@"Anytime", nil);
    
    //apply day
    self.day = self.day;
    
    //apply time
    self.time = self.time;
    
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
    [buttonDayTime release], buttonDayTime = nil;
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
    [buttonDayTime release];
    [wing release];
    [location release];
    [user release];
    [doubleDatesViewController release];
    [day release];
    [time release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

+ (NSString*)titleForDDDoubleDateProperty:(NSString*)property
{
    if ([property isEqualToString:DDDoubleDateDayPrefWeekday])
        return NSLocalizedString(@"Weekday", nil);
    else if ([property isEqualToString:DDDoubleDateDayPrefWeekend])
        return NSLocalizedString(@"Weekend", nil);
    else if ([property isEqualToString:DDDoubleDateTimePrefDaytime])
        return NSLocalizedString(@"During the Day", nil);
    else if ([property isEqualToString:DDDoubleDateTimePrefNighttime])
        return NSLocalizedString(@"At Night", nil);
    return NSLocalizedString(@"Anytime", nil);
}

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
    locationChooserViewController.location = self.location;
    locationChooserViewController.options = DDLocationSearchOptionsBoth;
    [self.navigationController pushViewController:locationChooserViewController animated:YES];
}

- (IBAction)dayTimeTouched:(id)sender
{
    DDCreateDoubleDateViewControllerChooseDate *viewController = [[[DDCreateDoubleDateViewControllerChooseDate alloc] init] autorelease];
    viewController.day = self.day;
    viewController.time = self.time;
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
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
    self.buttonWing.normalIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"create-dd-unselected-wing.png"]] autorelease];
    
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

- (void)setLocation:(DDLocation *)v
{
    //update value
    if (location != v)
    {
        [location release];
        location = [v retain];
    }
    
    //apply blank image by default
    self.buttonLocation.normalIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"create-dd-unselected-location.png"]] autorelease];
    
    //set text by default
    self.buttonLocation.text = nil;
    
    //unset right view by default
    self.buttonLocation.rightView = nil;
    
    //apply location
    if (location)
    {
        //apply image
        self.buttonLocation.normalIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"create-dd-selected-location.png"]] autorelease];
        
        //set location text
        self.buttonLocation.text = [location name];
        
        //set close button
        UIImage *closeImage = [UIImage imageNamed:@"search-clear-button.png"];
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(0, 0, closeImage.size.width, closeImage.size.height);
        [closeButton addTarget:self action:@selector(resetLocationTouched:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setBackgroundImage:closeImage forState:UIControlStateNormal];
        self.buttonLocation.rightView = closeButton;
    }
    
    //update navigation button
    [self updateNavigationBar];
}

- (void)setDay:(NSString *)v
{
    //save value
    if (day != v)
    {
        [day release];
        day = [v retain];
    }
    
    //update day and time
    [self updateDayTime];
}

- (void)setTime:(NSString *)v
{
    //save value
    if (time != v)
    {
        [time release];
        time = [v retain];
    }
    
    //update day and time
    [self updateDayTime];
}

- (void)updateDayTime
{
    if (self.day && self.time)
    {
        self.buttonDayTime.text = [NSString stringWithFormat:@"%@, %@", [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:self.day], [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:self.time]];
    }
    else if (self.day)
        self.buttonDayTime.text = [NSString stringWithFormat:@"%@", [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:self.day]];
    else if (self.time)
        self.buttonDayTime.text = [NSString stringWithFormat:@"%@", [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:self.time]];
    else
        self.buttonDayTime.text = [NSString stringWithFormat:@"%@", [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:nil]];

}

- (void)resetLocationTouched:(id)sender
{
    self.location = nil;
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
#pragma mark DDWingsViewControllerDelegate

- (void)wingsViewController:(DDWingsViewController*)viewController didSelectUser:(DDShortUser*)aUser
{
    [self setWing:aUser];
    [viewController.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark DDLocationPickerViewControllerDelegate

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
    return NO;
}

- (void)locationManagerDidFoundPlacemarks:(NSArray*)placemarks
{
}

#pragma mark -
#pragma mark API

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
#pragma mark UITextFieldDelegate

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
#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateNavigationBar];
}

#pragma mark -
#pragma mark DDCreateDoubleDateViewControllerChooseDateDelegate

- (void)createDoubleDateViewControllerChooseDateUpdatedDayTime:(id)sender
{
    self.day = [(DDCreateDoubleDateViewControllerChooseDate*)sender day];
    self.time = [(DDCreateDoubleDateViewControllerChooseDate*)sender time];
}

@end
