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
#import "DDBarButtonItem.h"
#import "DDIconTableViewCell.h"
#import "DDTextViewTableViewCell.h"
#import "DDAuthenticationController.h"
#import "DDTools.h"
#import "DDTools.h"
#import "Mixpanel.h"
#import "DDFacebookFriendsViewController.h"
#import "DDUserView.h"

#define kTagCancelActionSheet 1

@interface DDCreateDoubleDateViewController () <DDCreateDoubleDateViewControllerChooseWingDelegate, DDLocationPickerViewControllerDelegate, UITextViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, DDSelectFacebookFriendViewControllerDelegate>

@property(nonatomic, retain) DDPlacemark *location;
@property(nonatomic, retain) DDPlacemark *optionalLocation;

@property(nonatomic, retain) NSString *details;

@property(nonatomic, assign) BOOL selectingVenue;

@end

@implementation DDCreateDoubleDateViewController

@synthesize wing;
@synthesize location;
@synthesize optionalLocation;
@synthesize tableView;
@synthesize buttonCancel;
@synthesize buttonCreate;
@synthesize details;
@synthesize selectingVenue;

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
    
    //apply wing
    self.wing = self.wing;
    
    //apply location
    self.location = self.location;
    
    //apply user location if no location exist
    if (!self.location)
        self.location = [DDLocationController currentLocationController].lastPlacemark;
    
    //update navigation bar
    [self updateNavigationBar];
    
    //update header
    [self updateHeader];
    
    //add tap recognizer
    UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)] autorelease];
    tapRecognizer.delegate = self;
    [self.tableView addGestureRecognizer:tapRecognizer];
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
    [tableView release];
    [buttonCancel release];
    [buttonCreate release];
    [details release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (void)setWing:(DDShortUser *)v
{
    //update value
    if (wing != v)
    {
        [wing release];
        wing = [v retain];
    }
    
    [[Mixpanel sharedInstance] track:@"Create DoubleDate, Chose Wing"];
    
    //update header
    [self updateHeader];
    
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
    doubleDate.details = self.details;
    doubleDate.wing = [[[DDShortUser alloc] init] autorelease];
    if (self.wing.identifier)
        doubleDate.wing.identifier = self.wing.identifier;
    else if (self.wing.facebookId)
        doubleDate.wing.facebookId = self.wing.facebookId;
    doubleDate.user = [[[DDShortUser alloc] init] autorelease];
    doubleDate.user.identifier = [[DDAuthenticationController currentUser] userId];
    doubleDate.location = [[[DDPlacemark alloc] init] autorelease];
    if (self.optionalLocation)
        doubleDate.location.identifier = self.optionalLocation.identifier;
    else
        doubleDate.location.identifier = self.location.identifier;
    
    //show hud
    [self showHudWithText:NSLocalizedString(@"Creating", @"DoubleDate is being created hud/status text") animated:YES];
    
    //request friends
    [self.apiController createDoubleDate:doubleDate];
    
    [[Mixpanel sharedInstance] track:@"Create DoubleDate, Complete"];
}

- (void)backTouched:(id)sender
{
    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure?", nil)
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"No, Continue", @"Cancel date menu, continue creating date")
                                          destructiveButtonTitle:NSLocalizedString(@"Yes, Cancel", @"Cancel date menu, actually cancel")
                                               otherButtonTitles:nil, nil] autorelease];
    sheet.tag = kTagCancelActionSheet;
    [sheet showInView:self.view];
}

- (void)updateNavigationBar
{
    //update right button
    BOOL rightButtonEnabled = YES;
    NSString *detailsToCheck = [self.details stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([detailsToCheck length] == 0)
        rightButtonEnabled = NO;
    if (!self.location)
        rightButtonEnabled = NO;
    if (!self.wing)
        rightButtonEnabled = NO;
    self.buttonCreate.enabled = rightButtonEnabled;
}

- (void)updateHeader
{
    //the value of user viwe from xib
    CGFloat height = 186;
    
    //create header view
    UIView *mainView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height)] autorelease];
    [DDTools styleDualUserView:mainView];
    self.tableView.tableHeaderView = mainView;
    
    //add me
    DDUserView *meView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DDUserView class]) owner:self options:nil] objectAtIndex:0];
    meView.frame = CGRectMake(15, 10, 140, height - 10);
    meView.user = [DDAuthenticationController currentUser];
    meView.customTitle = NSLocalizedString(@"You", @"Title under mine photo");
    [mainView addSubview:meView];
    
    //add wing if needed
    if (self.wing)
    {
        //add user view
        DDUserView *wingView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DDUserView class]) owner:self options:nil] objectAtIndex:0];
        wingView.frame = CGRectMake(165, 10, 140, height - 10);
        wingView.shortUser = self.wing;
        [mainView addSubview:wingView];
        
        //add transparent button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, wingView.frame.size.width, wingView.frame.size.height);
        [button addTarget:self action:@selector(chooseWingTouched:) forControlEvents:UIControlEventTouchUpInside];
        [wingView addSubview:button];
    }
    else
    {
        //add transparent button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor colorWithRed:0 green:152/255.0f blue:216/255.0f alpha:0.2f];
        button.layer.cornerRadius = 10.0f;
        
        // add blue border
        button.layer.borderWidth = 2.0f;
        button.layer.borderColor = [UIColor colorWithRed:19/255.0f green:197/255.0f blue:255/255.0f alpha:1.0].CGColor;
        
        // add outer glow
        button.layer.shadowOffset = CGSizeMake(0,0);
        button.layer.shadowColor = [UIColor colorWithRed:0 green:152/255.0f blue:216/255.0f alpha:1.0].CGColor;
        button.layer.shadowRadius = 3.0f;
        button.layer.shadowOpacity = 0.5f;

        button.frame = CGRectMake(150+12, 7, 146, 146);
        
        [button addTarget:self action:@selector(chooseWingTouched:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:button];
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

- (void)updateDetailsCell:(DDTextViewTableViewCell*)cell
{
    //apply title
    cell.textView.text = self.details;
    
    //update delegate
    cell.textView.textView.delegate = self;
    
    //set placeholder
    cell.textView.placeholder = NSLocalizedString(@"Explain the details...", @"Placeholder text for details of new DoubleDate.");
    
    //set return button on post details
    cell.textView.textView.returnKeyType = UIReturnKeyDone;
}

- (NSIndexPath*)locationIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:1];
}

- (NSIndexPath*)optionalLocationIndexPath
{
    return [NSIndexPath indexPathForRow:1 inSection:1];
}

- (NSIndexPath*)detailsIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:0];
}

- (DDTextView*)textViewDetails
{
    return [(DDTextViewTableViewCell*)[self.tableView cellForRowAtIndexPath:[self detailsIndexPath]] textView];
}

- (void)dismissKeyboard
{
    UIResponder *responder = nil;
    responder = [[self textViewDetails] textView];
    if ([responder isFirstResponder])
        [responder resignFirstResponder];
}

- (void)tap:(UITapGestureRecognizer*)tapRecognizer
{
    [self dismissKeyboard];
}

- (void)chooseWingTouched:(id)sender
{
    //open view controller
    DDSelectFacebookFriendViewController *viewController = [[[DDSelectFacebookFriendViewController alloc] init] autorelease];
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
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
#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    //update details
    self.details = [[self textViewDetails] text];
    
    //update navigation bar
    [self updateNavigationBar];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //check for pressed done button
    if ( [text isEqualToString:@"\n"] )
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
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
        [self dismissKeyboard];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:[self detailsIndexPath]] == NSOrderedSame)
        return 100;
    else if ([indexPath compare:[self locationIndexPath]] == NSOrderedSame)
        return 45;
    return [DDTableViewCell height];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check pressed cell
    if ([indexPath compare:[self locationIndexPath]] == NSOrderedSame)
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
        return 1;
    else if (section == 1)
        return 2;
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
        if ([indexPath compare:[self locationIndexPath]] == NSOrderedSame || [indexPath compare:[self optionalLocationIndexPath]] == NSOrderedSame)
            cell = [[[DDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        //create text view table view cell
        else if ([indexPath compare:[self detailsIndexPath]] == NSOrderedSame)
            cell = [[[DDTextViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    //apply table view style
    [cell applyGroupedBackgroundStyleForTableView:aTableView withIndexPath:indexPath];
    
    //check index path
    if ([indexPath compare:[self locationIndexPath]] == NSOrderedSame)
        [self updateLocationCell:cell];
    else if ([indexPath compare:[self optionalLocationIndexPath]] == NSOrderedSame)
        [self updateOptionalLocationCell:cell];
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
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[gestureRecognizer locationInView:self.tableView]];
    return (indexPath == nil);
}

#pragma mark -
#pragma mark DDSelectFacebookFriendViewControllerDelegate

- (void)selectFacebookFriendViewControllerDidSelectWing:(DDShortUser*)user
{
    //set wing
    self.wing = user;
    
    //pop view controller
    [self.navigationController popViewControllerAnimated:YES];
}

@end
