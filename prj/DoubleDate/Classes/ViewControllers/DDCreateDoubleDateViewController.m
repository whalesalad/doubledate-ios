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
#import "UIImage+DD.h"
#import "DDUsersView.h"

#define kTagCancelActionSheet 1
#define kMapViewCornerRadius 6

@interface DDCreateDoubleDateViewController () <DDCreateDoubleDateViewControllerChooseWingDelegate, DDLocationPickerViewControllerDelegate, UITextViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, DDSelectFacebookFriendViewControllerDelegate>

@property(nonatomic, retain) DDPlacemark *location;

@property(nonatomic, retain) NSString *details;

@property(nonatomic, retain) MKMapView *mapView;

@end

@implementation DDCreateDoubleDateViewController

@synthesize wing;
@synthesize location;
@synthesize tableView;
@synthesize buttonCancel;
@synthesize buttonCreate;
@synthesize details;
@synthesize mapView;

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
    self.navigationItem.title = NSLocalizedString(@"New DoubleDate", nil);
    
    //set left button
    self.navigationItem.leftBarButtonItem = nil;
    
    //unset background color of the table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    
    //update images of the buttons
    [self.buttonCreate setBackgroundImage:[[self.buttonCreate backgroundImageForState:UIControlStateNormal] resizableImage] forState:UIControlStateNormal];
    [self.buttonCreate setBackgroundImage:[[self.buttonCreate backgroundImageForState:UIControlStateDisabled] resizableImage] forState:UIControlStateDisabled];
    [self.buttonCancel setBackgroundImage:[[self.buttonCancel backgroundImageForState:UIControlStateNormal] resizableImage] forState:UIControlStateNormal];
    
    //set handlers for button
    [self.buttonCancel addTarget:self action:@selector(backTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonCreate addTarget:self action:@selector(postTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    //apply wing
    self.wing = self.wing;
        
    //update navigation bar
    [self updateNavigationBar];
    
    //update header
    [self updateHeader];
    
    //add tap recognizer
    UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)] autorelease];
    tapRecognizer.delegate = self;
    [self.tableView addGestureRecognizer:tapRecognizer];
    
    //create map view
    self.mapView = [[MKMapView alloc] init];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.clipsToBounds = YES;
    self.mapView.layer.cornerRadius = kMapViewCornerRadius;
    self.mapView.showsUserLocation = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //show navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    //load facebook friends
    if (!facebookFriends_)
        [self.apiController getFacebookFriends];
    
    //reload the table as we need to update the map
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [wing release];
    [location release];
    [tableView release];
    [buttonCancel release];
    [buttonCreate release];
    [details release];
    [mapView release];
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
    //check the same value
    if (location != v)
    {
        //update value
        [location release];
        location = [v retain];
    }
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
        //add users view
        DDUsersView *usersView = [[[DDUsersView alloc] initWithFrame:CGRectMake(165, 10, 140, 140) rows:4 columns:4] autorelease];
        usersView.users = facebookFriends_;
        [mainView addSubview:usersView];
        
        //add transparent button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor colorWithRed:0 green:152/255.0f blue:216/255.0f alpha:0.1f];
        button.layer.cornerRadius = 10.0f;
        
        // add blue border
        button.layer.borderWidth = 1.0f;
        button.layer.borderColor = [UIColor colorWithRed:19/255.0f green:197/255.0f blue:255/255.0f alpha:1.0].CGColor;
        
        // add outer glow
        button.layer.shadowOffset = CGSizeMake(0,0);
        button.layer.shadowColor = [UIColor colorWithRed:0 green:152/255.0f blue:216/255.0f alpha:1.0].CGColor;
        button.layer.shadowRadius = 3.0f;
        button.layer.shadowOpacity = 0.3f;

        button.frame = CGRectMake(161, 6, 148, 148);
        
        [button addTarget:self action:@selector(chooseWingTouched:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:button];
        
        CGRect selectWingLabelFrame = usersView.bounds;
        selectWingLabelFrame.origin.y = 5;
        selectWingLabelFrame.size.width = selectWingLabelFrame.size.width - 44;
        
        UILabel *selectWingLabel = [[[UILabel alloc] initWithFrame:selectWingLabelFrame] autorelease];
        selectWingLabel.text = @"Select\nWing";
        
        selectWingLabel.backgroundColor = [UIColor clearColor];
        selectWingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
        selectWingLabel.textColor = [UIColor whiteColor];
        selectWingLabel.numberOfLines = 2;
        selectWingLabel.textAlignment = NSTextAlignmentRight;
        
        // shadow
        selectWingLabel.layer.shadowOpacity = 0.75f;
        selectWingLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        selectWingLabel.layer.shadowOffset = CGSizeMake(0, 1);
        selectWingLabel.layer.shadowRadius = 1.0f;
        
        [button addSubview:selectWingLabel];
        
        UIImage *selectWingArrow = [UIImage imageNamed:@"select-wing-right-arrow.png"];
        UIImageView *selectWingArrowView = [[[UIImageView alloc] initWithImage:selectWingArrow] autorelease];
        
        CGPoint arrowCenter = selectWingLabel.center;
        arrowCenter.x = arrowCenter.x + selectWingArrow.size.width + selectWingLabel.frame.size.width/2 + 3;
        selectWingArrowView.center = arrowCenter;
        
        [button addSubview:selectWingArrowView];
        
//        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//        pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//        pulseAnimation.duration = 0.6;
//        pulseAnimation.repeatCount = HUGE_VAL;
//        pulseAnimation.autoreverses = YES;
//        pulseAnimation.fromValue = [NSNumber numberWithFloat:0.98f];
//        pulseAnimation.toValue = [NSNumber numberWithFloat:1.02f];
//        [button.layer addAnimation:pulseAnimation forKey:@"transform"];
    }
}

- (UIImageView*)updateCell:(DDTableViewCell*)cell withIcon:(UIImage*)icon loadedFromUrl:(NSURL*)url
{
    //unset default image
    cell.imageView.image = [UIImage clearImageOfSize:CGSizeMake(28, 32)];
    
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

- (void)updateMapCell:(DDTableViewCell*)cell
{
    //unset selection style
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //check location
    if (self.location)
    {
        //clips to bounds cell
        cell.clipsToBounds = YES;
        cell.contentView.clipsToBounds = YES;
        
        //stretch to neeeded size
        self.mapView.frame = CGRectMake(0, 0, cell.contentView.bounds.size.width, cell.contentView.bounds.size.height + kMapViewCornerRadius);
        
        //add mapview
        [cell.contentView addSubview:self.mapView];
        
        //apply location to map view
        MKCoordinateRegion region;
        region.center = CLLocationCoordinate2DMake([self.location.latitude doubleValue], [self.location.longitude doubleValue]);
        MKCoordinateSpan span;
        CGFloat oneMileDistanceDelta = 0.0144927536;
        span.latitudeDelta = 10 * oneMileDistanceDelta;
        span.longitudeDelta = 10 * oneMileDistanceDelta;
        region.span = span;
        [self.mapView setRegion:region];
    }
    else
    {
        //remove map kit
        [self.mapView removeFromSuperview];
        
        //check the error
        if ([DDLocationController currentLocationController].errorPlacemark)
        {
#warning Michael add error overlay here
        }
        else
        {
#warning Michael add dummy overlay here
        }
    }
}

- (void)updateLocationCell:(DDTableViewCell*)cell
{
    //enable touch
    cell.userInteractionEnabled = YES;
    
    //check exist location
    if (self.location)
    {
        //apply blank image by default
        [self updateCell:cell withIcon:[UIImage clearImageOfSize:CGSizeMake(28, 32)] loadedFromUrl:[NSURL URLWithString:self.location.iconRetina]];
        
        //set location text
        cell.textLabel.text = [self.location venue];
        cell.detailTextLabel.text = [self.location locationName];
        
        //apply style
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        
        //add distance
        NSInteger tagLabelDistance = 2134;
        UILabel *labelDistance = (UILabel*)[cell.contentView viewWithTag:tagLabelDistance];
        if (!labelDistance)
        {
            labelDistance = [[[UILabel alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - 90, 0, 80, cell.contentView.frame.size.height)] autorelease];
            labelDistance.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            labelDistance.textAlignment = NSTextAlignmentRight;
            labelDistance.backgroundColor = [UIColor clearColor];
            labelDistance.textColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:labelDistance];
        }
        labelDistance.text = [NSString stringWithFormat:@"%dkm", [self.location.distance intValue]];
    }
    else if ([DDLocationController currentLocationController].errorPlacemark)
    {
        //apply style
        cell.textLabel.textColor = [UIColor grayColor];
        
        //set text
        cell.textLabel.text = NSLocalizedString(@"Please enable location services.", nil);
        
        //disable touch
        cell.userInteractionEnabled = NO;
    }
    else
    {
        //apply blank image by default
        UIImageView *imageView = [self updateCell:cell withIcon:[UIImage imageNamed:@"create-date-plus-icon.png"] loadedFromUrl:nil];
        
        //set alpha for blank image
        imageView.alpha = 0.5f;
        
        //set location text
        cell.textLabel.text = NSLocalizedString(@"Add a Venue", nil);
        
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

- (NSIndexPath*)mapIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:1];
}

- (NSIndexPath*)locationIndexPath
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
    //set optional location
    self.location = [placemarks objectAtIndex:0];
    
    //reload only one cell
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    //update navigation bar
    [self updateNavigationBar];
    
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

- (void)getFacebookFriendsSucceed:(NSArray *)friends
{
    //update facebook friends
    [facebookFriends_ release];
    facebookFriends_ = [friends retain];
    
    //update header
    [self updateHeader];
}

- (void)getFacebookFriendsDidFailedWithError:(NSError *)error
{
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

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    return [[self tableView:aTableView viewForHeaderInSection:section] frame].size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = nil;
    if (section == 0)
    {
        headerView = [self oldStyleViewForHeaderWithMainText:NSLocalizedString(@"Details", @"Create Date: Header view for details text view") detailedText:nil];
        UILabel *mainLabel = [self mainLabelForHeaderView:headerView];
        mainLabel.textColor = [UIColor whiteColor];
    }
    return headerView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView)
        [self dismissKeyboard];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:[self detailsIndexPath]] == NSOrderedSame)
        return 100;
    else if ([indexPath compare:[self mapIndexPath]] == NSOrderedSame)
        return 90;
    else if ([indexPath compare:[self locationIndexPath]] == NSOrderedSame)
        return 45;
    return [DDTableViewCell height];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check pressed cell
    if ([indexPath compare:[self locationIndexPath]] == NSOrderedSame)
    {
        DDLocationChooserViewController *locationChooserViewController = [[[DDLocationChooserViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        locationChooserViewController.delegate = self;
        locationChooserViewController.ddLocation = [[DDLocationController currentLocationController] lastPlacemark];
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
        if ([indexPath compare:[self mapIndexPath]] == NSOrderedSame)
            cell = [[[DDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        else if ([indexPath compare:[self locationIndexPath]] == NSOrderedSame)
            cell = [[[DDTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
        //create text view table view cell
        else if ([indexPath compare:[self detailsIndexPath]] == NSOrderedSame)
            cell = [[[DDTextViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    //apply table view style
    [cell applyGroupedBackgroundStyleForTableView:aTableView withIndexPath:indexPath];
    
    //check index path
    if ([indexPath compare:[self mapIndexPath]] == NSOrderedSame)
        [self updateMapCell:cell];
    else if ([indexPath compare:[self locationIndexPath]] == NSOrderedSame)
        [self updateLocationCell:cell];
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
