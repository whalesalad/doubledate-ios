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
#import "DDBarButtonItem.h"

#define kMaxBioLength 250
#define kMaxInterestsCount 10

@interface DDEditProfileViewController () <DDLocationPickerViewControllerDelegate, UITextViewDelegate>

@property(nonatomic, retain) UILabel *labelLeftCharacters;

- (NSInteger)numberOfAvailableInterests;
- (void)updateLeftCharacters;

@end

@implementation DDEditProfileViewController

@synthesize tableView;
@synthesize labelLeftCharacters;

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
    
    //set right button
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Done", nil) target:self action:@selector(doneTouched:)];
}

- (void)dealloc
{
    [user_ release];
    [tableView release];
    [labelLeftCharacters release];
    [super dealloc];
}

#pragma mark other

- (NSInteger)numberOfAvailableInterests
{
    return 6;
}

- (void)updateLeftCharacters
{
    self.labelLeftCharacters.text = [NSString stringWithFormat:@"%d/%d", kMaxBioLength-[user_.bio length], kMaxBioLength];
}

- (void)updateBioCell:(DDTextViewTableViewCell*)cell
{
    //set text
    cell.textView.text = user_.bio;
    
    //set placeholder
    cell.textView.placeholder = NSLocalizedString(@"Enter the bio", nil);
    
    //handle change of the text
    cell.textView.textView.delegate = self;
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
    //add button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"Add an Ice Breaker", nil) forState:UIControlStateNormal];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    button.frame = CGRectMake(20, 5, cell.contentView.frame.size.width-40, cell.contentView.frame.size.height-8);
    UIImage *image = [UIImage imageNamed:@"blue-icon-button.png"];
    [button setBackgroundImage:[image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2, image.size.width-7, image.size.height/2, 7)] forState:UIControlStateNormal];
    UIImage *icon = [UIImage imageNamed:@"plus-icon-for-button.png"];
    [button setImage:icon forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -62, 0, 0);
    [cell.contentView addSubview:button];
}

- (void)updateInterestCell:(DDTableViewCell*)cell withInterest:(DDInterest*)interest
{
    //add text
    cell.textLabel.text = [interest name];
    
    //add remove button
    UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeButton setFrame:CGRectMake(0, 0, 15, 16)];
    [removeButton setBackgroundImage:[UIImage imageNamed:@"remove-interest-button.png"] forState:UIControlStateNormal];
    [removeButton addTarget:self action:@selector(resetInterestTouched:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = removeButton;
}

- (void)resetInterestTouched:(id)sender
{
    //get cell
    UITableViewCell *cell = sender;
    while (cell && ![cell isKindOfClass:[UITableViewCell class]])
        cell = (UITableViewCell*)cell.superview;
    
    //get index path of the cell
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    
    //remove interest
    NSMutableArray *newInterests = [NSMutableArray arrayWithArray:user_.interests];
    [newInterests removeObjectAtIndex:cellIndexPath.row];
    user_.interests = newInterests;
    
    //update table view
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)doneTouched:(id)sender
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Updating", nil) animated:YES];
    
    //copy only needed fields
    DDUser *userToSend = [[[DDUser alloc] init] autorelease];
    userToSend.userId = [user_ userId];
    userToSend.bio = user_.bio;
    userToSend.interests = user_.interests;
    userToSend.location = user_.location;
    
    //set request
    [self.apiController updateMe:userToSend];
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
        //create new one view
        UIView *headerView = [self oldStyleViewForHeaderWithMainText:NSLocalizedString(@"YOUR BIO", nil) detailedText:NSLocalizedString(@"SHORT N' SWEET", nil)];
        
        //check for new label
        if (self.labelLeftCharacters)
        {
            [self.labelLeftCharacters removeFromSuperview];
            self.labelLeftCharacters = nil;
        }
        
        //add new label
        self.labelLeftCharacters = [[[UILabel alloc] initWithFrame:CGRectMake(220, 8, 80, 18)] autorelease];
        [headerView addSubview:self.labelLeftCharacters];
        [self updateLeftCharacters];
        
        return headerView;
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
    {
        BOOL addButtonExist = [user_.interests count] < kMaxInterestsCount;
        return [[user_ interests] count]+(int)addButtonExist;
    }
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
        if (scrollView != cell.textView.textView && [cell.textView.textView isFirstResponder])
            [cell.textView.textView resignFirstResponder];
    }
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    //change text
    user_.bio = textView.text;
    
    //update label
    [self updateLeftCharacters];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return newLength <= kMaxBioLength;
}

#pragma mark api

- (void)updateMeSucceed:(DDUser*)user
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

- (void)updateMeDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
