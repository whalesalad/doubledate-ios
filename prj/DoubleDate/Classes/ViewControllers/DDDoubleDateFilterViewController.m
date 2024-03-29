//
//  DDDoubleDateFilterViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 14.11.12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDDoubleDateFilterViewController.h"
#import "DDTools.h"
#import "DDButton.h"
#import "DDBarButtonItem.h"
#import "DDDoubleDateFilter.h"
#import "DDUser.h"
#import "DDShortUser.h"
#import "DDLocationChooserViewController.h"
#import "DDPlacemark.h"
#import "DDLabelTableViewCell.h"
#import "DDLabel.h"
#import "DDLocationController.h"

#define kMinAge 17
#define kMaxAge 50

@interface DDDoubleDateFilterViewController () <DDLocationPickerViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property(nonatomic, retain) UILabel *labelAge;

@end

@implementation DDDoubleDateFilterViewController

@synthesize delegate;

@synthesize labelAge;

- (id)initWithFilter:(DDDoubleDateFilter*)filter
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        filter_ = [[DDDoubleDateFilter alloc] init];
        filter_.minAge = filter.minAge;
        filter_.maxAge = filter.maxAge;
        filter_.query = filter.query;
        filter_.location = filter.location;
   }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Filter Results", @"Title for filter doubledates view");
    
    //remove search
    self.tableView.tableHeaderView = nil;
    
    //remove refresh
    self.refreshControl = nil;
    
    //disable scrolling
    self.tableView.scrollEnabled = NO;
    
    //set initial content inset
    self.tableView.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0);
    
    //set right button
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Done", nil) target:self action:@selector(applyTouched:)];
    
    //set left button
    self.navigationItem.leftBarButtonItem = nil;
    
    //check for default value
    if (filter_.location == nil)
        filter_.location = [DDLocationController currentLocationController].lastPlacemark;

    
    //check for default min/max values
    if (filter_.minAge == nil)
        filter_.minAge = [NSNumber numberWithInt:kMinAge];
    if (filter_.maxAge == nil)
        filter_.maxAge = [NSNumber numberWithInt:kMaxAge];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //show navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //open age picker view
    DDLabelTableViewCell *cell = (DDLabelTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    if ([cell isKindOfClass:[DDLabelTableViewCell class]])
        [cell.label becomeFirstResponder];
}

- (void)dealloc
{
    [filter_ release];
    [labelAge release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (void)applyTouched:(id)sender
{
    //check for nil location
    if ([[filter_.location identifier] intValue] == [[[[DDLocationController currentLocationController] lastPlacemark] identifier] intValue])
        filter_.location = nil;
    
    //apply filter
    [self.delegate doubleDateFilterViewControllerDidAppliedFilter:filter_];
}

- (void)cancelTouched:(id)sender
{
    [self.delegate doubleDateFilterViewControllerDidCancel];
}

- (void)updateLocationCell:(DDTableViewCell*)cell
{
    //enable/disable touch
    cell.userInteractionEnabled = YES;
    
    //check exist location
    if (filter_.location)
    {
        //apply blank image by default
        cell.imageView.image = [UIImage imageNamed:@"create-date-location-icon.png"];
        
        //set location text
        cell.textLabel.text = [filter_.location name];
        
        //apply style
        cell.textLabel.textColor = [UIColor whiteColor];
        
        //check if we need to add reset button
        if ([[[[DDLocationController currentLocationController] lastPlacemark] identifier] intValue] != [[filter_.location identifier] intValue])
        {
            UIImage *cancelImage = [UIImage imageNamed:@"x-icon.png"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.frame = CGRectMake(0, 0, 30, 30);
            cell.accessoryView = button;
            [button setImage:cancelImage forState:UIControlStateNormal];
            [button addTarget:self action:@selector(resetLocationTouched:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else
    {
        //apply blank image by default
        cell.imageView.image = [UIImage imageNamed:@"create-date-location-icon.png"];
        
        //set location text
        cell.textLabel.text = NSLocalizedString(@"Choose a nearby city…", @"Label for no city chosen in filter menu.");
        
        //apply style
        cell.textLabel.textColor = [UIColor grayColor];
    }
}

- (NSString*)ageTitle
{
    return [NSString stringWithFormat:NSLocalizedString(@"%d to %d", @"AGE to AGE label."), [filter_.minAge intValue], [filter_.maxAge intValue]];
}

- (void)resetLocationTouched:(id)sender
{
    //set location
    filter_.location = [DDLocationController currentLocationController].lastPlacemark;
    
    //update cell
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)tap
{
    if ([self.labelAge isFirstResponder])
        [self.labelAge resignFirstResponder];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return FLT_MIN;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    return [[self tableView:aTableView viewForHeaderInSection:section] frame].size.height;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = nil;
    if (section == 0)
        headerView = [self oldStyleViewForHeaderWithMainText:NSLocalizedString(@"Near", @"Filter header for choosing nearby city") detailedText:nil];
    else if (section == 1)
        headerView = [self oldStyleViewForHeaderWithMainText:NSLocalizedString(@"Age Range", @"Filter header for choosing range of ages") detailedText:nil];
    [headerView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)] autorelease]];
    return headerView;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0)
    {
        DDLocationChooserViewController *locationChooserViewController = [[[DDLocationChooserViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        locationChooserViewController.delegate = self;
        locationChooserViewController.options = DDLocationSearchOptionsCities;

        if ([[filter_.location identifier] intValue] != [[[[DDLocationController currentLocationController] lastPlacemark] identifier] intValue])
            locationChooserViewController.ddLocation = filter_.location;
        else
            locationChooserViewController.clLocation = [DDLocationController currentLocationController].lastLocation;

        [self.navigationController pushViewController:locationChooserViewController animated:YES];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        //create cell
        DDTableViewCell *cell = [[[DDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        
        //apply style
        [cell applyGroupedBackgroundStyleForTableView:tableView withIndexPath:indexPath];
        
        //update location cell
        [self updateLocationCell:cell];
        
        return cell;
    }
    else if (indexPath.section == 1)
    {
        //create cell
        DDLabelTableViewCell *cell = [[[DDLabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        
        //save text field
        self.labelAge = cell.label;
        
        //unset selection style
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //set text
        cell.label.text = [self ageTitle];
        
        //enable touch
        cell.label.userInteractionEnabled = YES;
        
        //set picker
        UIPickerView *picker = [[[UIPickerView alloc] init] autorelease];
        picker.delegate = self;
        picker.dataSource = self;
        picker.showsSelectionIndicator = YES;
        cell.label.inputView = picker;
        
        //select needed row
        [picker selectRow:[filter_.minAge intValue]-kMinAge inComponent:0 animated:NO];
        [picker selectRow:[filter_.maxAge intValue]-kMinAge inComponent:1 animated:NO];
        
        //apply style
        [cell applyGroupedBackgroundStyleForTableView:tableView withIndexPath:indexPath];
        
        return cell;
    }
    
    return nil;
}

#pragma mark DDLocationPickerViewControllerDelegate

- (void)locationPickerViewControllerDidFoundPlacemarks:(NSArray*)placemarks
{
    //set location
    filter_.location = [placemarks objectAtIndex:0];
    
    //reload the table
    [self.tableView reloadData];
    
    //pop view controller
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)locationPickerViewControllerDidCancel
{
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return kMaxAge-kMinAge+1;
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%d", kMinAge + row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //update values
    if (component == 0)
        filter_.minAge = [NSNumber numberWithInt:kMinAge + row];
    else if (component == 1)
        filter_.maxAge = [NSNumber numberWithInt:kMinAge + row];
    
    //disable values
    if ([[filter_ minAge] intValue] > [[filter_ maxAge] intValue])
    {
        //update min age
        if (component == 1)
            filter_.minAge = filter_.maxAge;
        else
            filter_.maxAge = filter_.minAge;
        
        //update picker
        [pickerView selectRow:[filter_.minAge intValue]-kMinAge inComponent:0 animated:YES];
        [pickerView selectRow:[filter_.maxAge intValue]-kMinAge inComponent:1 animated:YES];
    }
    
    //update text view
    DDLabelTableViewCell *cell = (DDLabelTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    if ([cell isKindOfClass:[DDLabelTableViewCell class]])
        cell.label.text = [self ageTitle];
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}

@end
