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
#import "DDInterest.h"

@interface DDEditProfileViewController () <DDLocationPickerViewControllerDelegate>

- (NSInteger)numberOfAvailableInterests;

@end

@implementation DDEditProfileViewController

@synthesize tableView;

- (id)initWithUser:(DDUser*)user
{
    self = [super init];
    if (self)
    {
        user_ = [user copy];
        
        user_.interests = [NSMutableArray array];
        for (int i = 0; i < 3; i++)
        {
            DDInterest *interest = [[[DDInterest alloc] init] autorelease];
            interest.name = [NSString stringWithFormat:@"%d", i];
            [user_.interests addObject:interest];
        }
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
    [tableView release];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
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
}

- (void)updateAddInterestCell:(DDTableViewCell*)cell
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"Add an Ice Breaker", nil) forState:UIControlStateNormal];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    button.frame = CGRectMake(20, 5, cell.contentView.frame.size.width-40, cell.contentView.frame.size.height-8);
    UIImage *image = [UIImage imageNamed:@"blue-icon-button.png"];
    [button setBackgroundImage:[image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2, image.size.width-7, image.size.height/2, 7)] forState:UIControlStateNormal];
    [cell.contentView addSubview:button];
}

- (void)updateInterestCell:(DDTableViewCell*)cell withInterest:(DDInterest*)interest
{
    cell.textLabel.text = [interest name];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        return [font lineHeight]*4;
    }
    
    if (indexPath.section == 1)
        return [DDTableViewCell height];
    
    if (indexPath.section == 2)
        return 50;
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
        return FLT_MIN;
    else if (section == 1)
        return FLT_MIN;
    else if (section == 2)
        return 10;
    return 0;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    return [[self tableView:aTableView viewForHeaderInSection:section] frame].size.height;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    if ([self tableView:aTableView numberOfRowsInSection:section] == 0)
        return nil;
    
    if (section == 0)
    {
        return [self oldStyleViewForHeaderWithMainText:NSLocalizedString(@"YOUR BIO", nil) detailedText:NSLocalizedString(@"SHORT N' SWEET", nil)];
    }
    
    if (section == 1)
    {
        return [self oldStyleViewForHeaderWithMainText:NSLocalizedString(@"YOUR LOCATION", nil) detailedText:nil];
    }
    
    if (section == 2)
    {
        return [self oldStyleViewForHeaderWithMainText:NSLocalizedString(@"ICE BREAKERS", nil) detailedText:[NSString stringWithFormat:NSLocalizedString(@"Add up to %d more", nil), [self numberOfAvailableInterests]]];
    }
    
    return nil;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //open location chooser
    if (indexPath.section == 1)
    {
        DDLocationChooserViewController *locationChooserViewController = [[[DDLocationChooserViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        locationChooserViewController.ddLocation = user_.location;
        locationChooserViewController.options = DDLocationSearchOptionsCities;
        locationChooserViewController.delegate = self;
        [self.navigationController pushViewController:locationChooserViewController animated:YES];
    }
    
    //deselect row
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else if (section == 1)
        return 1;
    else if (section == 2)
        return [[user_ interests] count]+1;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //bio
    if (indexPath.section == 0)
    {
        //create cell
        DDTextViewTableViewCell *cell = [[[DDTextViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        
        //apply styling for cell
        [cell applyGroupedBackgroundStyleForTableView:aTableView withIndexPath:indexPath];
        
        //update content
        [self updateBioCell:cell];
        
        return cell;
    }
    //location
    else if (indexPath.section == 1)
    {
        //create cell
        DDIconTableViewCell *cell = [[[DDIconTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        
        //apply styling for cell
        [cell applyGroupedBackgroundStyleForTableView:aTableView withIndexPath:indexPath];
        
        //update content
        [self updateLocationCell:cell];
        
        return cell;
    }
    //interests
    else if (indexPath.section == 2)
    {
        //check for last object - add button
        if (indexPath.row == [[user_ interests] count])
        {
            //create cell
            DDTableViewCell *cell = [[[DDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
            
            //apply styling for cell
            [cell applyGroupedBackgroundStyleForTableView:aTableView withIndexPath:indexPath];
            
            //update content
            [self updateAddInterestCell:cell];
            
            return cell;
        }
        else
        {
            //create cell
            DDTableViewCell *cell = [[[DDTableViewCell alloc] init] autorelease];
            
            //apply styling for cell
            [cell applyGroupedBackgroundStyleForTableView:aTableView withIndexPath:indexPath];
            
            //update content
            [self updateInterestCell:cell withInterest:(DDInterest*)[[user_ interests] objectAtIndex:indexPath.row]];

            return cell;
        }
    }
    
    assert(0);
}

#pragma mark 

- (void)locationPickerViewControllerDidFoundPlacemarks:(NSArray*)placemarks
{
    //set location
    user_.location = [placemarks objectAtIndex:0];
    
    //reload location
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    //pop view controller
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)locationPickerViewControllerDidCancel
{
    
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    DDTextViewTableViewCell *cell = (DDTextViewTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([cell isKindOfClass:[DDTextViewTableViewCell class]])
    {
        if ([cell.textView.textView isFirstResponder])
            [cell.textView.textView resignFirstResponder];
    }
}

@end
