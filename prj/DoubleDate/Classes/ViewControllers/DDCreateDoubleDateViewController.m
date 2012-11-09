//
//  DDCreateDoubleDateViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDCreateDoubleDateViewController.h"
#import "DDShortUser.h"
#import "DDCreateDoubleDateViewControllerChooseWing.h"
#import "DDImageView.h"
#import "DDPlacemark.h"
#import "DDLocationChooserViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DDTextView.h"
#import "DDDoubleDate.h"
#import "DDDoubleDatesViewController.h"
#import "DDCreateDoubleDateViewControllerChooseDate.h"
#import "DDBarButtonItem.h"
#import "DDIconTableViewCell.h"
#import "DDTextFieldTableViewCell.h"
#import "DDTextField.h"
#import "DDTextViewTableViewCell.h"

@interface DDCreateDoubleDateViewController () <DDCreateDoubleDateViewControllerChooseWingDelegate, DDLocationPickerViewControllerDelegate, DDLocationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, DDCreateDoubleDateViewControllerChooseDateDelegate>

@property(nonatomic, retain) DDShortUser *wing;
@property(nonatomic, retain) DDPlacemark *location;
@property(nonatomic, retain) NSError *locationError;

@property(nonatomic, retain) NSString *day;
@property(nonatomic, retain) NSString *time;

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *details;

@end

@implementation DDCreateDoubleDateViewController

@synthesize wing;
@synthesize location;
@synthesize locationError;
@synthesize user;
@synthesize doubleDatesViewController;
@synthesize day;
@synthesize time;
@synthesize tableView;
@synthesize title;
@synthesize details;

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
    
    //unset background color of the table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    
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
    [super viewDidUnload];
    [tableView release], tableView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    locationController_.delegate = nil;
    [locationController_ release];
    [wing release];
    [location release];
    [locationError release];
    [user release];
    [doubleDatesViewController release];
    [day release];
    [time release];
    [tableView release];
    [title release];
    [details release];
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

- (void)setWing:(DDShortUser *)v
{
    //update value
    if (wing != v)
    {
        [wing release];
        wing = [v retain];
    }
    
    //update cell
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self wingIndexPath]] withRowAnimation:UITableViewRowAnimationNone];
    
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
    
    //update cell
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self locationIndexPath]] withRowAnimation:UITableViewRowAnimationNone];
        
    //update navigation button
    [self updateNavigationBar];
}

- (void)setLocationError:(NSError *)v
{
    //update value
    if (locationError != v)
    {
        [locationError release];
        locationError = [v retain];
    }
    
    //update cell
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self locationIndexPath]] withRowAnimation:UITableViewRowAnimationNone];
    
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
    
    //update cell
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self dayTimeIndexPath]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setTime:(NSString *)v
{
    //save value
    if (time != v)
    {
        [time release];
        time = [v retain];
    }
    
    //update cell
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self dayTimeIndexPath]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)resetLocationTouched:(id)sender
{
    self.location = nil;
}

- (void)postTouched:(id)sender
{
    //set up double date
    DDDoubleDate *doubleDate = [[[DDDoubleDate alloc] init] autorelease];
    doubleDate.title = self.title;
    doubleDate.details = self.details;
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
    if ([self.title length] == 0)
        rightButtonEnabled = NO;
    if ([self.details length] == 0)
        rightButtonEnabled = NO;
    if (!self.location)
        rightButtonEnabled = NO;
    if (!self.wing)
        rightButtonEnabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = rightButtonEnabled;
}

- (void)updateWingCell:(DDIconTableViewCell*)cell
{
    //apply blank image by default
    cell.iconImageView.image = [UIImage imageNamed:@"create-dd-unselected-wing.png"];
    
    //set left text
    cell.leftText = NSLocalizedString(@"wing", nil);
    
    //set right placeholder
    cell.rightPlaceholder = NSLocalizedString(@"Choose a wing...", nil);
    
    //unset right text
    cell.rightText = nil;
    
    //unset accessory view
    cell.accessoryView = nil;
    
    //apply location
    if (wing)
    {
        //load image
        if ([[wing photo] downloadUrl])
        {
            DDImageView *imageView = cell.iconImageView;
            imageView.layer.cornerRadius = 17;
            imageView.layer.masksToBounds = YES;
            [imageView reloadFromUrl:[NSURL URLWithString:[[wing photo] downloadUrl]]];
        }
        
        //set location text
        cell.rightText = [wing fullName];
    }
}

- (void)updateLocationCell:(DDIconTableViewCell*)cell
{
    //apply blank image by default
    cell.iconImageView.image = [UIImage imageNamed:@"create-dd-unselected-location.png"];
    
    //set left text
    cell.leftText = NSLocalizedString(@"where", nil);
    
    //set right placeholder
    cell.rightPlaceholder = NSLocalizedString(@"Choose a location...", nil);
    
    //unset right text
    cell.rightText = nil;
    
    //unset accessory view
    cell.accessoryView = nil;
    
    //enable/disable touch
    cell.userInteractionEnabled = locationError == nil;
    
    //apply location
    if (locationError)
    {
        cell.rightPlaceholder = NSLocalizedString(@"Failed to find location", nil);
    }
    else if (location)
    {
        //apply image
        cell.iconImageView.image = [UIImage imageNamed:@"create-dd-selected-location.png"];
        
        //set location text
        cell.rightText = [location name];
        
        //set close button
        UIImage *closeImage = [UIImage imageNamed:@"search-clear-button.png"];
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(0, 0, closeImage.size.width, closeImage.size.height);
        [closeButton addTarget:self action:@selector(resetLocationTouched:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setBackgroundImage:closeImage forState:UIControlStateNormal];
        cell.accessoryView = closeButton;
    }
}

- (void)updateDayTimeCell:(DDIconTableViewCell*)cell
{
    //apply blank image by default
    cell.iconImageView.image = [UIImage imageNamed:@"create-dd-selected-daytime.png"];
    
    //set left text
    cell.leftText = NSLocalizedString(@"when", nil);
    
    //set right placeholder
    cell.rightPlaceholder = NSLocalizedString(@"Choose a day/time...", nil);
    
    //unset right text
    cell.rightText = NSLocalizedString(@"Anytime", nil);
    
    //set text
    if (self.day && self.time)
    {
        cell.rightText = [NSString stringWithFormat:@"%@, %@", [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:self.day], [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:self.time]];
    }
    else if (self.day)
        cell.rightText = [NSString stringWithFormat:@"%@", [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:self.day]];
    else if (self.time)
        cell.rightText = [NSString stringWithFormat:@"%@", [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:self.time]];
    else
        cell.rightText = [NSString stringWithFormat:@"%@", [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:nil]];
}

- (void)updateTitleCell:(DDTextFieldTableViewCell*)cell
{
    //apply title
    cell.textField.text = self.title;
    
    //update delegate
    cell.textField.delegate = self;
    
    //set next button
    cell.textField.returnKeyType = UIReturnKeyNext;
    
    //set placeholder
    cell.textField.placeholder = NSLocalizedString(@"Title", nil);
}

- (void)updateDetailsCell:(DDTextViewTableViewCell*)cell
{
    //apply title
    cell.textView.text = self.details;
    
    //update delegate
    cell.textView.textView.delegate = self;
    
    //set placeholder
    cell.textView.placeholder = NSLocalizedString(@"Have any extra details?", nil);
}

- (NSIndexPath*)wingIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:1];
}

- (NSIndexPath*)locationIndexPath
{
    return [NSIndexPath indexPathForRow:1 inSection:1];
}

- (NSIndexPath*)dayTimeIndexPath
{
    return [NSIndexPath indexPathForRow:2 inSection:1];
}

- (NSIndexPath*)titleIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:0];
}

- (NSIndexPath*)detailsIndexPath
{
    return [NSIndexPath indexPathForRow:1 inSection:0];
}

- (DDTextField*)textFieldTitle
{
    return [(DDTextFieldTableViewCell*)[self.tableView cellForRowAtIndexPath:[self titleIndexPath]] textField];
}

- (DDTextView*)textViewDetails
{
    return [(DDTextViewTableViewCell*)[self.tableView cellForRowAtIndexPath:[self detailsIndexPath]] textView];
}

#pragma mark -
#pragma mark DDLocationPickerViewControllerDelegate

- (void)locationPickerViewControllerDidFoundPlacemarks:(NSArray*)placemarks
{
    [self setLocation:[placemarks objectAtIndex:0]];
}

- (void)locationPickerViewControllerDidCancel
{
}

#pragma mark -
#pragma mark DDLocationControllerDlegate

- (void)locationManagerDidFoundLocation:(CLLocation*)location
{
    
}

- (void)locationManagerDidFailedWithError:(NSError*)error
{
    //save location error
    self.locationError = error;
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
    [[[self textViewDetails] textView] becomeFirstResponder];
    return YES;
}

- (void)textFieldTextDidChange:(NSNotification*)notification
{
    if ([notification object] == [self textFieldTitle])
    {
        //update title
        self.title = [[self textFieldTitle] text];
        
        //update navigation bar
        [self updateNavigationBar];
    }
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    //update details
    self.details = [[self textViewDetails] text];
    
    //update navigation bar
    [self updateNavigationBar];
}

#pragma mark -
#pragma mark DDCreateDoubleDateViewControllerChooseDateDelegate

- (void)createDoubleDateViewControllerChooseDateUpdatedDayTime:(id)sender
{
    self.day = [(DDCreateDoubleDateViewControllerChooseDate*)sender day];
    self.time = [(DDCreateDoubleDateViewControllerChooseDate*)sender time];
}

#pragma mark -
#pragma mark DDCreateDoubleDateViewControllerChooseWingDelegate

- (void)createDoubleDateViewControllerChooseWingUpdatedWing:(id)sender
{
    self.wing = [(DDCreateDoubleDateViewControllerChooseWing*)sender wing];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([[[self textViewDetails] textView] isFirstResponder])
        [[[self textViewDetails] textView] resignFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:[self detailsIndexPath]] == NSOrderedSame)
        return 100;
    return [DDTableViewCell height];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check pressed cell
    if ([indexPath compare:[self wingIndexPath]] == NSOrderedSame)
    {
        DDCreateDoubleDateViewControllerChooseWing *wingsViewController = [[[DDCreateDoubleDateViewControllerChooseWing alloc] init] autorelease];
        wingsViewController.delegate = self;
        wingsViewController.wing = self.wing;
        [self.navigationController pushViewController:wingsViewController animated:YES];
    }
    else if ([indexPath compare:[self locationIndexPath]] == NSOrderedSame)
    {
        DDLocationChooserViewController *locationChooserViewController = [[[DDLocationChooserViewController alloc] init] autorelease];
        locationChooserViewController.delegate = self;
        if (self.location)
            locationChooserViewController.ddLocation = self.location;
        else
            locationChooserViewController.clLocation = locationController_.location;
        locationChooserViewController.options = DDLocationSearchOptionsVenues;
        [self.navigationController pushViewController:locationChooserViewController animated:YES];
    }
    else if ([indexPath compare:[self dayTimeIndexPath]] == NSOrderedSame)
    {
        DDCreateDoubleDateViewControllerChooseDate *viewController = [[[DDCreateDoubleDateViewControllerChooseDate alloc] init] autorelease];
        viewController.day = self.day;
        viewController.time = self.time;
        viewController.delegate = self;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
    //unselect row
    [aTableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 2;
    else if (section == 1)
        return 3;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set cell identifier
    NSString *cellIdentifier = [NSString stringWithFormat:@"s%dr%d", indexPath.section, indexPath.row];
    
    //get exist cell
    DDTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        //create icon table view cell
        if ([indexPath compare:[self wingIndexPath]] == NSOrderedSame || [indexPath compare:[self locationIndexPath]] == NSOrderedSame || [indexPath compare:[self dayTimeIndexPath]] == NSOrderedSame)
            cell = [[[DDIconTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        //create text field table view cell
        else if ([indexPath compare:[self titleIndexPath]] == NSOrderedSame)
            cell = [[[DDTextFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        //create text view table view cell
        else if ([indexPath compare:[self detailsIndexPath]] == NSOrderedSame)
            cell = [[[DDTextViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    //apply table view style
    [cell applyGroupedBackgroundStyleForTableView:aTableView withIndexPath:indexPath];
    
    //check index path
    if ([indexPath compare:[self wingIndexPath]] == NSOrderedSame)
        [self updateWingCell:(DDIconTableViewCell*)cell];
    else if ([indexPath compare:[self locationIndexPath]] == NSOrderedSame)
        [self updateLocationCell:(DDIconTableViewCell*)cell];
    else if ([indexPath compare:[self dayTimeIndexPath]] == NSOrderedSame)
        [self updateDayTimeCell:(DDIconTableViewCell*)cell];
    else if ([indexPath compare:[self titleIndexPath]] == NSOrderedSame)
        [self updateTitleCell:(DDTextFieldTableViewCell*)cell];
    else if ([indexPath compare:[self detailsIndexPath]] == NSOrderedSame)
        [self updateDetailsCell:(DDTextViewTableViewCell*)cell];
    
    return cell;
}

@end
