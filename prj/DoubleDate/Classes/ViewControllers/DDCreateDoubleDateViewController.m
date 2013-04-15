//
//  DDCreateDoubleDateViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
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
#import "DDCreateDoubleDateViewControllerChooseDate.h"
#import "DDBarButtonItem.h"
#import "DDIconTableViewCell.h"
#import "DDTextFieldTableViewCell.h"
#import "DDTextField.h"
#import "DDTextViewTableViewCell.h"
#import "DDAuthenticationController.h"
#import "DDTools.h"
#import "DDAppDelegate+WingsMenu.h"
#import "DDTools.h"
#import "Mixpanel.h"

#define kTagCancelActionSheet 1

@interface DDCreateDoubleDateViewController () <DDCreateDoubleDateViewControllerChooseWingDelegate, DDLocationPickerViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate, DDCreateDoubleDateViewControllerChooseDateDelegate, UIActionSheetDelegate, DDChooseWingViewDelegate>

@property(nonatomic, retain) DDPlacemark *location;
@property(nonatomic, retain) DDPlacemark *optionalLocation;

@property(nonatomic, retain) NSString *day;
@property(nonatomic, retain) NSString *time;

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *details;

@property(nonatomic, assign) BOOL selectingVenue;

@end

@implementation DDCreateDoubleDateViewController

@synthesize wing;
@synthesize location;
@synthesize optionalLocation;
@synthesize day;
@synthesize time;
@synthesize tableView;
@synthesize buttonCancel;
@synthesize buttonCreate;
@synthesize title;
@synthesize details;
@synthesize selectingVenue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[Mixpanel sharedInstance] track:@"Create DoubleDate Started"];
    
    //localize
    [buttonCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [buttonCreate setTitle:NSLocalizedString(@"Create", nil) forState:UIControlStateNormal];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Create a DoubleDate", nil);
    
    //set left button
    self.navigationItem.leftBarButtonItem = nil;
    
    //unset background color of the table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    
    //update images of the buttons
    [self.buttonCreate setBackgroundImage:[DDTools resizableImageFromImage:[self.buttonCreate backgroundImageForState:UIControlStateNormal]] forState:UIControlStateNormal];
    [self.buttonCreate setBackgroundImage:[DDTools resizableImageFromImage:[self.buttonCreate backgroundImageForState:UIControlStateDisabled]] forState:UIControlStateDisabled];
    [self.buttonCancel setBackgroundImage:[DDTools resizableImageFromImage:[self.buttonCancel backgroundImageForState:UIControlStateNormal]] forState:UIControlStateNormal];
    
    //set handlers for button
    [self.buttonCancel addTarget:self action:@selector(backTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonCreate addTarget:self action:@selector(postTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    //apply day
    self.day = self.day;
    
    //apply time
    self.time = self.time;
    
    //apply wing
    self.wing = self.wing;
    
    //apply location
    self.location = self.location;
    
    //apply user location if no location exist
    if (!self.location)
        self.location = [DDLocationController currentLocationController].lastPlacemark;
    
    //update navigation bar
    [self updateNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //show navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [wing release];
    [location release];
    [optionalLocation release];
    [day release];
    [time release];
    [tableView release];
    [buttonCancel release];
    [buttonCreate release];
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

+ (NSString*)titleForDDDay:(NSString*)day ddTime:(NSString*)time
{
    if (day && time)
    {
        return [NSString stringWithFormat:@"%@, %@", [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:day], [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:time]];
    }
    else if (day)
        return [NSString stringWithFormat:@"%@", [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:day]];
    else if (time)
        return [NSString stringWithFormat:@"%@", [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:time]];
    else
        return [NSString stringWithFormat:@"%@", [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:nil]];
    return nil;
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
    //update the location
    self.location = [DDLocationController currentLocationController].lastPlacemark;

    //clear optional location
    self.optionalLocation = nil;
    
    //update cell
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    
    //update navigation button
    [self updateNavigationBar];
}

- (void)resetOptionalLocationTouched:(id)sender
{
    //clear optional location
    self.optionalLocation = nil;
    
    //update cell
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)postTouched:(id)sender
{
    //set up double date
    DDDoubleDate *doubleDate = [[[DDDoubleDate alloc] init] autorelease];
    doubleDate.title = self.title;
    doubleDate.details = self.details;
    doubleDate.wing = [[[DDShortUser alloc] init] autorelease];
    doubleDate.wing.identifier = self.wing.identifier;
    doubleDate.user = [[[DDShortUser alloc] init] autorelease];
    doubleDate.user.identifier = [[DDAuthenticationController currentUser] userId];
    doubleDate.location = [[[DDPlacemark alloc] init] autorelease];
    if (self.optionalLocation)
        doubleDate.location.identifier = self.optionalLocation.identifier;
    else
        doubleDate.location.identifier = self.location.identifier;
    doubleDate.dayPref = self.day;
    doubleDate.timePref = self.time;
    
    //show hud
    [self showHudWithText:NSLocalizedString(@"Creating", nil) animated:YES];
    
    //request friends
    [self.apiController createDoubleDate:doubleDate];
    
    [[Mixpanel sharedInstance] track:@"Create DoubleDate, Complete"];
}

- (void)backTouched:(id)sender
{
    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Oops, Continue", nil) destructiveButtonTitle:NSLocalizedString(@"Yes, Stop Creating Date", nil) otherButtonTitles:nil, nil] autorelease];
    sheet.tag = kTagCancelActionSheet;
    [sheet showInView:self.view];
}

- (void)updateNavigationBar
{
    //update right button
    BOOL rightButtonEnabled = YES;
    NSString *titleToCheck = [self.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([titleToCheck length] == 0)
        rightButtonEnabled = NO;
    NSString *detailsToCheck = [self.details stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([detailsToCheck length] == 0)
        rightButtonEnabled = NO;
    if (!self.location)
        rightButtonEnabled = NO;
    if (!self.wing)
        rightButtonEnabled = NO;
    self.buttonCreate.enabled = rightButtonEnabled;
}

- (void)updateWingCell:(DDTableViewCell*)cell
{
    //check if we need to update the wing
    if (self.wing)
    {
        //set wing label
        cell.textLabel.text = [wing fullName];
        
        //add image view
        DDImageView *imageView = [[[DDImageView alloc] init] autorelease];
        imageView.frame = CGRectMake(cell.contentView.frame.size.width - 76, 0, 76, 45);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [imageView applyMask:[UIImage imageNamed:@"wing-tablecell-item-mask.png"]];
        [cell.contentView addSubview:imageView];
        
        //add overlay
        UIImageView *overlay = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wing-tablecell-item-overlay.png"]] autorelease];
        [imageView addSubview:overlay];
                
        //update image view
        [imageView reloadFromUrl:[NSURL URLWithString:[self.wing photo].smallUrl]];
        
        [[Mixpanel sharedInstance] track:@"Create DoubleDate, Chose Wing"];
    }
    else
    {
        //set placeholder
        cell.textLabel.text = NSLocalizedString(@"Choose a Wing", nil);
        
        //set text color
        cell.textLabel.textColor = [UIColor grayColor];
    }
}

- (UIImageView*)updateCell:(DDTableViewCell*)cell withIcon:(UIImage*)icon loadedFromUrl:(NSURL*)url
{
    //unset default image
    cell.imageView.image = [DDTools clearImageOfSize:CGSizeMake(28, 32)];
    
    //set center of image view
    CGPoint center = CGPointMake(20, cell.contentView.frame.size.height/2+2);
    
    //add image view
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:icon] autorelease];
    if (url)
        [imageView setImageWithURL:url placeholderImage:icon completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (!error)
            {
                imageView.image = image;
                imageView.highlightedImage = image;
                imageView.frame = CGRectMake(0, 0, 32, 32);
                imageView.center = center;
            }
        }];
    imageView.center = center;
    [cell.contentView addSubview:imageView];
    return imageView;
}

- (void)updateLocationCell:(DDTableViewCell*)cell
{
    //enable/disable touch
    cell.userInteractionEnabled = self.location != nil;
    
    //check exist location
    if (self.location)
    {
        //apply blank image by default
        [self updateCell:cell withIcon:[UIImage imageNamed:@"create-date-location-icon.png"] loadedFromUrl:nil];
        
        //set location text
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Near %@", @"The city location when creating a DoubleDate."), location.name];
        
        //apply style
        cell.textLabel.textColor = [UIColor whiteColor];
        
        //check if we need to add reset button
        if ([[[[DDLocationController currentLocationController] lastPlacemark] identifier] intValue] != [[self.location identifier] intValue])
        {
            UIImage *cancelImage = [UIImage imageNamed:@"button-icon-cancel.png"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.frame = CGRectMake(0, 0, 30, 30);
            cell.accessoryView = button;
            [button setImage:cancelImage forState:UIControlStateNormal];
            [button addTarget:self action:@selector(resetLocationTouched:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else if ([DDLocationController currentLocationController].errorPlacemark)
    {
        //apply style
        cell.textLabel.textColor = [UIColor grayColor];
        
        //set text
        cell.textLabel.text = NSLocalizedString(@"Please enable location services.", nil);
    }
    else
    {
        //apply blank image by default
        [self updateCell:cell withIcon:[UIImage imageNamed:@"create-date-location-icon.png"] loadedFromUrl:nil];

        //set location text
        cell.textLabel.text = NSLocalizedString(@"Choose a location", nil);
        
        //apply style
        cell.textLabel.textColor = [UIColor grayColor];
    }
}

- (void)updateOptionalLocationCell:(DDTableViewCell*)cell
{
    //check exist location
    if (self.optionalLocation)
    {
        //apply blank image by default
        [self updateCell:cell withIcon:[DDTools clearImageOfSize:CGSizeMake(28, 32)] loadedFromUrl:[NSURL URLWithString:self.optionalLocation.iconRetina]];
        
        //set location text
        if ([self.optionalLocation address]){
            cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", [self.optionalLocation name], [self.optionalLocation address]];
        } else {
            cell.textLabel.text = [self.optionalLocation name];
        }
        
        //apply style
        cell.textLabel.textColor = [UIColor whiteColor];
        
        //add reset button
        UIImage *cancelImage = [UIImage imageNamed:@"button-icon-cancel.png"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        button.frame = CGRectMake(0, 0, 30, 30);
        cell.accessoryView = button;
        [button setImage:cancelImage forState:UIControlStateNormal];
        [button addTarget:self action:@selector(resetOptionalLocationTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (!self.location)
    {
        //apply style
        cell.textLabel.textColor = [UIColor grayColor];
        
        //set text
        cell.textLabel.text = NSLocalizedString(@"Please enable location services.", nil);
    }
    else
    {
        //apply blank image by default
        UIImageView *imageView = [self updateCell:cell withIcon:[UIImage imageNamed:@"create-date-plus-icon.png"] loadedFromUrl:nil];
        
        //set alpha for blank image
        imageView.alpha = 0.5f;
        
        //set location text
        cell.textLabel.text = NSLocalizedString(@"Add an Optional Venue", nil);
        
        //apply style
        cell.textLabel.textColor = [UIColor grayColor];
    }
}

- (void)updateDayTimeCell:(DDTableViewCell*)cell
{
    //apply blank image by default
//    cell.imageView.image = [UIImage imageNamed:@"create-date-time-icon.png"];
    UIImageView *imageView = [self updateCell:cell withIcon:[UIImage imageNamed:@"create-date-time-icon.png"] loadedFromUrl:nil];
    imageView.center = CGPointMake(20, cell.contentView.frame.size.height/2);
    
    //set text
    cell.textLabel.text = [DDCreateDoubleDateViewController titleForDDDay:self.day ddTime:self.time];

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
    cell.textField.placeholder = NSLocalizedString(@"Write a creative title...", nil);
}

- (void)updateDetailsCell:(DDTextViewTableViewCell*)cell
{
    //apply title
    cell.textView.text = self.details;
    
    //update delegate
    cell.textView.textView.delegate = self;
    
    //set placeholder
    cell.textView.placeholder = NSLocalizedString(@"Explain your DoubleDate. Be creative!", nil);
}

- (NSIndexPath*)wingIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:0];
}

- (NSIndexPath*)locationIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:2];
}

- (NSIndexPath*)optionalLocationIndexPath
{
    return [NSIndexPath indexPathForRow:1 inSection:2];
}

- (NSIndexPath*)dayTimeIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:3];
}

- (NSIndexPath*)titleIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:1];
}

- (NSIndexPath*)detailsIndexPath
{
    return [NSIndexPath indexPathForRow:1 inSection:1];
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
    if (!self.selectingVenue)
    {
        //set location
        self.location = [placemarks objectAtIndex:0];
    
        //clear optional location
        self.optionalLocation = nil;
    
        //update cell
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    
        //update navigation button
        [self updateNavigationBar];
    }
    else
    {
        //set optional location
        self.optionalLocation = [placemarks objectAtIndex:0];
        
        //reload only one cell
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    //pop view controller
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)locationPickerViewControllerDidCancel
{
}

#pragma mark -
#pragma mark API

- (void)createDoubleDateSucceed:(DDDoubleDate*)doubleDate
{
    //hide hud
    [self hideHud:YES];
    
    //show succeed message
    NSString *message = NSLocalizedString(@"Done", nil);
    
    //show completed hud
    [self showCompletedHudWithText:message];
    
    //go back
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
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
    //set wing
    self.wing = [(DDCreateDoubleDateViewControllerChooseWing*)sender wing];
    
    //pop view controller
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView)
    {
        if ([[[self textViewDetails] textView] isFirstResponder])
            [[[self textViewDetails] textView] resignFirstResponder];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:[self detailsIndexPath]] == NSOrderedSame)
        return 100;
    else if ([indexPath compare:[self titleIndexPath]] == NSOrderedSame)
        return 45;
    else if ([indexPath compare:[self wingIndexPath]] == NSOrderedSame)
        return 45;
    else if ([indexPath compare:[self locationIndexPath]] == NSOrderedSame)
        return 45;
    else if ([indexPath compare:[self dayTimeIndexPath]] == NSOrderedSame)
        return 45;
    return [DDTableViewCell height];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check pressed cell
    if ([indexPath compare:[self wingIndexPath]] == NSOrderedSame)
    {
        DDTextFieldTableViewCell *textFieldCell = (DDTextFieldTableViewCell*)[aTableView cellForRowAtIndexPath:[self titleIndexPath]];
        if ([textFieldCell isKindOfClass:[DDTextFieldTableViewCell class]] && [textFieldCell.textField isFirstResponder])
            [textFieldCell.textField resignFirstResponder];
        DDTextViewTableViewCell *textViewCell = (DDTextViewTableViewCell*)[aTableView cellForRowAtIndexPath:[self detailsIndexPath]];
        if ([textViewCell isKindOfClass:[DDTextFieldTableViewCell class]] && [textViewCell.textView.textView isFirstResponder])
            [textViewCell.textView.textView resignFirstResponder];
        [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] presentWingsMenuWithDelegate:self excludedUsers:nil];
    }
    else if ([indexPath compare:[self locationIndexPath]] == NSOrderedSame)
    {
        self.selectingVenue = NO;
        DDLocationChooserViewController *locationChooserViewController = [[[DDLocationChooserViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        locationChooserViewController.delegate = self;
        if ([[self.location identifier] intValue] != [[[[DDLocationController currentLocationController] lastPlacemark] identifier] intValue])
            locationChooserViewController.ddLocation = self.location;
        else
            locationChooserViewController.clLocation = [DDLocationController currentLocationController].lastLocation;
        locationChooserViewController.options = DDLocationSearchOptionsCities;
        locationChooserViewController.distance = 200;
        [self.navigationController pushViewController:locationChooserViewController animated:YES];
    }
    else if ([indexPath compare:[self optionalLocationIndexPath]] == NSOrderedSame)
    {
        self.selectingVenue = YES;
        DDLocationChooserViewController *locationChooserViewController = [[[DDLocationChooserViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        locationChooserViewController.delegate = self;
        locationChooserViewController.ddLocation = self.location;
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else if (section == 1)
        return 2;
    else if (section == 2)
        return 2;
    else if (section == 3)
        return 1;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set cell identifier
    NSString *cellIdentifier = [NSString stringWithFormat:@"s%dr%d", indexPath.section, indexPath.row];
    
    //get exist cell
    DDTableViewCell *cell = nil;//[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        //create icon table view cell
        if ([indexPath compare:[self wingIndexPath]] == NSOrderedSame || [indexPath compare:[self locationIndexPath]] == NSOrderedSame || [indexPath compare:[self dayTimeIndexPath]] == NSOrderedSame || [indexPath compare:[self optionalLocationIndexPath]] == NSOrderedSame)
            cell = [[[DDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
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
        [self updateWingCell:cell];
    else if ([indexPath compare:[self locationIndexPath]] == NSOrderedSame)
        [self updateLocationCell:cell];
    else if ([indexPath compare:[self optionalLocationIndexPath]] == NSOrderedSame)
        [self updateOptionalLocationCell:cell];
    else if ([indexPath compare:[self dayTimeIndexPath]] == NSOrderedSame)
        [self updateDayTimeCell:cell];
    else if ([indexPath compare:[self titleIndexPath]] == NSOrderedSame)
        [self updateTitleCell:(DDTextFieldTableViewCell*)cell];
    else if ([indexPath compare:[self detailsIndexPath]] == NSOrderedSame)
        [self updateDetailsCell:(DDTextViewTableViewCell*)cell];
    
    return cell;
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kTagCancelActionSheet && buttonIndex != actionSheet.cancelButtonIndex)
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [[Mixpanel sharedInstance] track:@"Create DoubleDate, Cancelled"];
        }];
}

#pragma mark -
#pragma mark DDChooseWingViewDelegate

- (void)chooseWingViewDidSelectUser:(DDShortUser*)user
{
    //set wing
    self.wing = user;
    
    //update
    [self updateNavigationBar];
    
    //update the cell
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self wingIndexPath]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
