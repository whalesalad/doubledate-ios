//
//  DDEditProfileViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 2/21/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDEditProfileViewController.h"
#import "DDTextViewTableViewCell.h"
#import "DDIconTableViewCell.h"
#import "DDImageView.h"
#import "DDTools.h"
#import "DDTextView.h"
#import "DDUser.h"
#import "DDLocationChooserViewController.h"

@interface DDEditProfileViewController () <DDLocationPickerViewControllerDelegate>

- (NSInteger)numberOfAvailableInterests;

@end

@implementation DDEditProfileViewController

@synthesize tableViewBio;
@synthesize tableViewLocation;
@synthesize tableViewInterests;

- (id)initWithUser:(DDUser*)user
{
    self = [super init];
    if (self)
    {
        user_ = [user copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Edit Profile", nil);
}

- (void)dealloc
{
    [user_ release];
    [tableViewBio release];
    [tableViewLocation release];
    [tableViewInterests release];
    [super dealloc];
}

#pragma mark other

- (NSInteger)numberOfAvailableInterests
{
    return 6;
}

- (void)updateBioCell:(DDTextViewTableViewCell*)cell
{
    //set text
    cell.textView.text = user_.bio;
    
    //set placeholder
    cell.textView.placeholder = NSLocalizedString(@"Enter the bio", nil);
    
    //handle change of the text
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bioTextDidChange:) name:UITextViewTextDidChangeNotification object:cell.textView.textView];
}

- (void)bioTextDidChange:(NSNotification*)notification
{
    //update bio
    user_.bio = [(UITextView*)[notification object] text];
}

- (void)updateLocationCell:(DDIconTableViewCell*)cell
{
    //apply blank image by default
    cell.iconImageView.image = [UIImage imageNamed:@"create-dd-unselected-location.png"];
    
    //set left text
    cell.leftText = NSLocalizedString(@"WHERE", nil);
    
    //set right placeholder
    cell.rightPlaceholder = NSLocalizedString(@"Choose a location...", nil);
    
    //unset right text
    cell.rightText = nil;
    
    //unset accessory view
    cell.accessoryView = nil;
    
    //update user's location
    if (user_.location)
    {
        //apply image
        cell.iconImageView.image = [UIImage imageNamed:@"create-dd-selected-location.png"];
        
        //set location text
        cell.rightText = [user_.location name];
        
        //set close button
        UIImage *closeImage = [UIImage imageNamed:@"search-clear-button.png"];
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(0, 0, closeImage.size.width, closeImage.size.height);
        [closeButton addTarget:self action:@selector(resetLocationTouched:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setBackgroundImage:closeImage forState:UIControlStateNormal];
        cell.accessoryView = closeButton;
    }
}

- (void)resetLocationTouched:(id)sender
{
    //unset location
    user_.location = nil;
    
    //reload the table
    [self.tableViewLocation reloadData];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewBio)
    {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        return [font lineHeight]*4;
    }
    
    if (tableView == self.tableViewLocation)
        return [DDTableViewCell height];
    
    if (tableView == self.tableViewInterests)
        return 88;
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForFooterInSection:(NSInteger)section
{
    return FLT_MIN;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    return [[self tableView:aTableView viewForHeaderInSection:section] frame].size.height;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    if ([self tableView:aTableView numberOfRowsInSection:section] == 0)
        return nil;
    
    if (aTableView == self.tableViewBio)
    {
        return [self oldStyleViewForHeaderWithMainText:NSLocalizedString(@"YOUR BIO", nil) detailedText:NSLocalizedString(@"SHORT N' SWEET", nil)];
    }
    
    if (aTableView == self.tableViewLocation)
    {
        return [self oldStyleViewForHeaderWithMainText:NSLocalizedString(@"YOUR LOCATION", nil) detailedText:nil];
    }
    
    if (aTableView == self.tableViewInterests)
    {
        return [self oldStyleViewForHeaderWithMainText:NSLocalizedString(@"ICE BREAKERS", nil) detailedText:[NSString stringWithFormat:NSLocalizedString(@"Add up to %d more", nil), [self numberOfAvailableInterests]]];
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //open location chooser
    if (tableView == self.tableViewLocation)
    {
        DDLocationChooserViewController *locationChooserViewController = [[[DDLocationChooserViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        locationChooserViewController.ddLocation = user_.location;
        locationChooserViewController.options = DDLocationSearchOptionsCities;
        locationChooserViewController.delegate = self;
        [self.navigationController pushViewController:locationChooserViewController animated:YES];
    }
    
    //deselect row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableViewBio)
        return 1;
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check bio
    if (tableView == self.tableViewBio)
    {
        DDTextViewTableViewCell *cell = [[[DDTextViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        [cell applyGroupedBackgroundStyleForTableView:tableView withIndexPath:indexPath];
        [self updateBioCell:cell];
        return cell;
    }
    else if (tableView == self.tableViewLocation)
    {
        DDIconTableViewCell *cell = [[[DDIconTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        [cell applyGroupedBackgroundStyleForTableView:tableView withIndexPath:indexPath];
        [self updateLocationCell:cell];
        return cell;
    }
    
    return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
}

#pragma mark 

- (void)locationPickerViewControllerDidFoundPlacemarks:(NSArray*)placemarks
{
    //set location
    user_.location = [placemarks objectAtIndex:0];
    
    //reload the table
    [self.tableViewLocation reloadData];
    
    //pop view controller
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)locationPickerViewControllerDidCancel
{
    
}

@end
