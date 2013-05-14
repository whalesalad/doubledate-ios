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
#import "DDSelectInterestsViewController.h"
#import "TITokenField.h"
#import "UIViewController+Extensions.h"
#import "DDAuthenticationController.h"
#import "DDSelectInterestsViewController.h"
#import "UIImage+DD.h"

#define kMaxBioLength 250
#define kMaxInterestsCount 10
#define kMinTextViewLinesNumber 4

@interface DDEditProfileViewController () <DDLocationPickerViewControllerDelegate, UITextViewDelegate, DDSelectInterestsViewControllerDelegate>

@property(nonatomic, retain) UILabel *labelLeftCharacters;
@property(nonatomic, retain) UITextView *textViewBio;

- (NSInteger)numberOfAvailableInterests;
- (void)updateLeftCharacters;
- (void)updateLeftInterests;

@end

@implementation DDEditProfileViewController

@synthesize tableView;
@synthesize labelLeftCharacters;
@synthesize textViewBio;

- (id)initWithUser:(DDUser*)user
{
    self = [super init];
    if (self)
    {
        user_ = [user copy];
        interestsHeaderViews_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Edit Profile", nil);
    
    //set right button
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Save", nil) target:self action:@selector(doneTouched:)];
    
    //add new label
    self.labelLeftCharacters = [[[UILabel alloc] initWithFrame:CGRectMake(220, 22, 80, 18)] autorelease];
    self.labelLeftCharacters.backgroundColor = [UIColor clearColor];
    self.labelLeftCharacters.textColor = [UIColor darkGrayColor];
    self.labelLeftCharacters.textAlignment = NSTextAlignmentRight;
    self.labelLeftCharacters.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    self.labelLeftCharacters.shadowOffset = CGSizeMake(0, -1);
    self.labelLeftCharacters.shadowColor = [UIColor colorWithWhite:0 alpha:0.6f];
    [self.tableView addSubview:self.labelLeftCharacters];
    [self updateLeftCharacters];
    
    [self performSelector:@selector(customizeTextViewAtFirst) withObject:nil afterDelay:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //update left interests
    [self updateLeftInterests];
    
    //remove all header views
    [interestsHeaderViews_ removeAllObjects];
    
    //show navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)customizeTextViewAtFirst
{
    [self.tableView reloadData];
    [self textViewDidChange:self.textViewBio];
}

- (void)dealloc
{
    [user_ release];
    [tableView release];
    [interestsHeaderViews_ release];
    [labelLeftCharacters release];
    [textViewBio release];
    [super dealloc];
}

#pragma mark other

- (void)applyInterestStylingForCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    //set cell style
    DDTableViewCellStyle style = DDTableViewCellStyleNone;
    if ([self.tableView numberOfRowsInSection:indexPath.section] <= 1)
        style = DDTableViewCellStyleGroupedSolid;
    else if (indexPath.row == 0)
        style = DDTableViewCellStyleGroupedTop;
    else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1)
        style = DDTableViewCellStyleGroupedBottom;
    else
        style = DDTableViewCellStyleGroupedCenter;
    
    //check needed style
    if (style != DDTableViewCellStyleNone)
    {
        switch (style) {
            case DDTableViewCellStyleGroupedTop:
                cell.backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"interest-tablecell-top-bg.png"] resizableImage]] autorelease];
                break;
            case DDTableViewCellStyleGroupedBottom:
                cell.backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"interest-tablecell-bottom-bg.png"] resizableImage]] autorelease];
                break;
            case DDTableViewCellStyleGroupedCenter:
                cell.backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"interest-tablecell-bg.png"] resizableImage]] autorelease];
                break;
            case DDTableViewCellStyleGroupedSolid:
                cell.backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"interest-tablecell-bg.png"] resizableImage]] autorelease];
                break;
            default:
                break;
        }
    }
    
}

- (NSInteger)numberOfAvailableInterests
{
    return kMaxInterestsCount - [user_.interests count];
}

- (void)updateLeftInterestsForView:(UIView*)headerView
{
    UILabel *label = [self detailedLabelForHeaderView:headerView];
    label.hidden = [self numberOfAvailableInterests] == 0;
    [label setText:[NSString stringWithFormat:NSLocalizedString(@"Add up to %d more", @"in reference to the number of interests you can add"), [self numberOfAvailableInterests]]];
}

- (void)updateLeftInterests
{
    for (UIView *v in interestsHeaderViews_)
        [self updateLeftInterestsForView:v];
}

- (void)updateLeftCharacters
{
    self.labelLeftCharacters.text = [NSString stringWithFormat:@"%d/%d", user_.bio.length, kMaxBioLength];
}

- (void)updateBioCell:(DDTextViewTableViewCell*)cell
{
    //set text
    cell.textView.text = user_.bio;
    
    //set placeholder
    cell.textView.placeholder = NSLocalizedString(@"Tell us about yourself :)", nil);
    
    //handle change of the text
    cell.textView.textView.delegate = self;
}

- (void)updateLocationCell:(DDTableViewCell*)cell
{
    //apply blank image by default
    cell.imageView.image = [UIImage imageNamed:@"edit-profile-location-icon.png"];
    
    //set location text
    cell.textLabel.text = [user_.location name];
}

- (void)resetLocationTouched:(id)sender
{
    //unset location
    user_.location = nil;
}

- (void)updateEmptyInterestCell:(DDTableViewCell*)cell
{
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.numberOfLines = 2;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = NSLocalizedString(@"What are the ten things that\nyou can't live without?", nil);
    label.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:16];
    label.textColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:label];
}

- (void)updateAddInterestCell:(DDTableViewCell*)cell
{
    //add button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"Add an Ice Breaker", nil) forState:UIControlStateNormal];

    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    button.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.2f];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    button.frame = CGRectMake(20, 12, cell.contentView.frame.size.width-40, 42);
    UIImage *image = [UIImage imageNamed:@"blue-icon-button.png"];
    [button setBackgroundImage:[image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2, image.size.width-7, image.size.height/2, 7)] forState:UIControlStateNormal];
    UIImage *icon = [UIImage imageNamed:@"plus-icon-for-button.png"];
    [button setImage:icon forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -42-icon.size.width/2, 0, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24, 0, 0);
    [cell.contentView addSubview:button];
    [button addTarget:self action:@selector(createInterestTouched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createInterestTouched:(id)sender
{
    //create veiw controller
    DDSelectInterestsViewController *viewController = [[[DDSelectInterestsViewController alloc] init] autorelease];
    viewController.selectedInterests = user_.interests;
    viewController.maxInterestsCount = kMaxInterestsCount;
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)updateInterestCell:(DDTableViewCell*)cell withInterest:(DDInterest*)interest
{
    //add text
    cell.textLabel.text = [interest name];
    
    //add remove button
    UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeButton setFrame:CGRectMake(0, 0, 40, 40)];
    [removeButton setImage:[UIImage imageNamed:@"remove-interest-button.png"] forState:UIControlStateNormal];
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
    if ([user_.interests count] == kMaxInterestsCount-1 || [user_.interests count] == 0)
    {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
    }
    else
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    //update styling of table view cells
    for (int i = 0; i < MIN([user_.interests count]+1, kMaxInterestsCount); i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:2];
        DDTableViewCell *cell = (DDTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [self applyInterestStylingForCell:cell withIndexPath:indexPath];
    }
    
    //update left interests
    [self updateLeftInterests];
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
        NSInteger numberOfLines = kMinTextViewLinesNumber;
        if (self.textViewBio)
        {
            font = self.textViewBio.font;
            numberOfLines = self.textViewBio.contentSize.height / [font lineHeight] + 1;
        }
        return [font lineHeight]*MAX(kMinTextViewLinesNumber, numberOfLines);
    }
    
    if (indexPath.section == 1)
        return [DDTableViewCell height];
    
    if (indexPath.section == 2)
    {
        if ([user_.interests count] < kMaxInterestsCount)
        {
            if ([user_.interests count] == 0)
            {
                if (indexPath.row == 0)
                    return 87;
                else
                    return 65;
            }
            else if ([user_.interests count] == indexPath.row)
                return 65;
        }
        return 50;
    }
    
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
        return [self oldStyleViewForHeaderWithMainText:NSLocalizedString(@"Your Bio", nil)
                                          detailedText:NSLocalizedString(@"Short n' Sweet", @"Editing profile: user bio sub-header detail text")];
    }
    
    if (section == 1)
    {
        return [self oldStyleViewForHeaderWithMainText:NSLocalizedString(@"Your Location", nil)
                                          detailedText:nil];
    }
    
    if (section == 2)
    {
        UIView *header = [self oldStyleViewForHeaderWithMainText:NSLocalizedString(@"Ice Breakers", @"Editing profile: interests header text.")
                                                    detailedText:@"                                    "];
        [interestsHeaderViews_ addObject:header];
        [self updateLeftInterestsForView:header];
        return header;
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
    return 2;
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
        BOOL dummyTopCellExists = [[user_ interests] count] == 0;
        return [[user_ interests] count]+(int)addButtonExist+(int)dummyTopCellExists;
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
        
        //save bio text view
        self.textViewBio = cell.textView.textView;
        
        //apply styling for cell
        [cell applyGroupedBackgroundStyleForTableView:aTableView withIndexPath:indexPath];
        
        //disable selection
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //update content
        [self updateBioCell:cell];
        
        return cell;
    }
    //location
    else if (indexPath.section == 1)
    {
        //create cell
        DDTableViewCell *cell = [[[DDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        
        //apply styling for cell
        [cell applyGroupedBackgroundStyleForTableView:aTableView withIndexPath:indexPath];
        
        //disable selection
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //update content
        [self updateLocationCell:cell];
        
        return cell;
    }
    //interests
    else if (indexPath.section == 2)
    {
        //apply type of button
        BOOL emptyInterestCell = [[user_ interests] count] == 0 && indexPath.row == 0;
        BOOL addInterestCell = ([[user_ interests] count] == 0 && indexPath.row == 1) || (indexPath.row == [[user_ interests] count]);
        
        //check the type of button
        if (emptyInterestCell)
        {
            //create cell
            DDTableViewCell *cell = [[[DDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
            
            //apply styling for cell
            [self applyInterestStylingForCell:cell withIndexPath:indexPath];
            
            //disable selection
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            //update content
            [self updateEmptyInterestCell:cell];
            
            return cell;
        }
        else if (addInterestCell)
        {
            //create cell
            DDTableViewCell *cell = [[[DDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
            
            //apply styling for cell
            [self applyInterestStylingForCell:cell withIndexPath:indexPath];
            
            //disable selection
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            //update content
            [self updateAddInterestCell:cell];
            
            return cell;
        }
        else
        {
            //create cell
            DDTableViewCell *cell = [[[DDTableViewCell alloc] init] autorelease];
            
            //apply styling for cell
            [self applyInterestStylingForCell:cell withIndexPath:indexPath];
            
            //disable selection
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
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
    
    //update table view height
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
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
    NSString *message = NSLocalizedString(@"Saved", nil);
    
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

#pragma mark DDSelectInterestsViewControllerDelegate

- (void)selectInterestsViewController:(DDSelectInterestsViewController*)viewController didSelectInterest:(DDInterest*)interest
{
    //add interest if not exist
    BOOL isExist = NO;
    for (DDInterest *i in user_.interests)
    {
        if ([[[i name] lowercaseString] isEqualToString:[[interest name] lowercaseString]])
            isExist = YES;
    }
    if (!isExist)
    {
        //update interests
        if (!user_.interests)
            user_.interests = [NSArray arrayWithObject:interest];
        else
            user_.interests = [user_.interests arrayByAddingObject:interest];
        
        //reload the data
        [self.tableView reloadData];
    }
    
    //go back
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)selectInterestsViewControllerDidCancel:(DDSelectInterestsViewController*)viewController
{
    //go back
    [self.navigationController popViewControllerAnimated:YES];
}

@end
