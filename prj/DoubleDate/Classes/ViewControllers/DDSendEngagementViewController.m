//
//  DDSendEngagementViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDSendEngagementViewController.h"
#import "UIImage+DD.h"
#import "DDShortUser.h"
#import "DDEngagement.h"
#import "DDTableViewCell.h"
#import "DDImageView.h"
#import "DDTextFieldTableViewCell.h"
#import "DDTextViewTableViewCell.h"
#import "DDTextField.h"
#import "DDTextView.h"
#import "DDFacebookFriendsViewController.h"
#import "DDStatisticsController.h"
#import "FBWebDialogs+DD.h"
#import <QuartzCore/QuartzCore.h>

#define kMaxDetailsLength 250

@interface DDSendEngagementViewController () <UITextFieldDelegate, UITextViewDelegate, DDSelectFacebookFriendViewControllerDelegate>

@property(nonatomic, retain) NSString *details;

@property(nonatomic, retain) DDShortUser *wing;

@property(nonatomic, retain) UILabel *labelLeftCharacters;

@end

@implementation DDSendEngagementViewController

@synthesize delegate;

@synthesize doubleDate;

@synthesize tableView;
@synthesize buttonCancel;
@synthesize buttonCreate;

@synthesize details;

@synthesize wing;

@synthesize labelLeftCharacters;

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
    
    //localize
    [buttonCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [buttonCreate setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"New Message", nil);
    
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
    
    //add new label
    self.labelLeftCharacters = [[[UILabel alloc] initWithFrame:CGRectMake(220, 88, 80, 18)] autorelease];
    self.labelLeftCharacters.backgroundColor = [UIColor clearColor];
    self.labelLeftCharacters.textColor = [UIColor darkGrayColor];
    self.labelLeftCharacters.textAlignment = NSTextAlignmentRight;
    self.labelLeftCharacters.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    self.labelLeftCharacters.shadowOffset = CGSizeMake(0, -1);
    self.labelLeftCharacters.shadowColor = [UIColor colorWithWhite:0 alpha:0.6f];
    [self.tableView addSubview:self.labelLeftCharacters];
    
    //update navigation bar
    [self updateNavigationBar];
    
    //update left characters label
    [self updateLeftCharacters];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //scroll to bottom before showing keyboard
    if (activateKeyboardCode_ == 1)
    {
        if (self.tableView.contentSize.height > self.tableView.bounds.size.height)
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height) animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check if we need to show keyboard
    if (activateKeyboardCode_ == 1)
    {
        activateKeyboardCode_++;
        [[[self textViewDetails] textView] becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [doubleDate release];
    [tableView release];
    [buttonCancel release];
    [buttonCreate release];
    [details release];
    [wing release];
    [labelLeftCharacters release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (void)postTouched:(id)sender
{
    //check for wing
    if (self.wing)
    {
        //show loading
        [self showHudWithText:NSLocalizedString(@"Creating", nil) animated:YES];
        
        //request api
        DDEngagement *engagement = [[[DDEngagement alloc] init] autorelease];
        engagement.activityId = self.doubleDate.identifier;
        if (self.wing.identifier)
            engagement.wingId = self.wing.identifier;
        else if (self.wing.facebookId)
            engagement.facebookId = self.wing.facebookId;
        engagement.message = self.details;
        [self.apiController createEngagement:engagement];
    }
}

- (void)backTouched:(id)sender
{
    [self.delegate sendEngagementViewControllerDidCancel];
}

- (void)updateNavigationBar
{
    //update right button
    BOOL rightButtonEnabled = YES;
    NSString *detailsToCheck = [self.details stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([detailsToCheck length] == 0)
        rightButtonEnabled = NO;
    if (!self.wing)
        rightButtonEnabled = NO;
    self.buttonCreate.enabled = rightButtonEnabled;
}

- (void)updateLeftCharacters
{
    self.labelLeftCharacters.text = [NSString stringWithFormat:@"%d / %d", [self.details length], kMaxDetailsLength];
}

- (void)updateWingCell:(DDTableViewCell*)cell
{
    //add image view
    DDImageView *imageView = [[[DDImageView alloc] init] autorelease];
    imageView.frame = CGRectMake(cell.contentView.frame.size.width - 46, 0, 46, 45);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    //check if we need to update the wing
    if (self.wing)
    {
        //set wing label
        cell.textLabel.text = [wing firstName];
        
        //update image view
        [imageView reloadFromUrl:[NSURL URLWithString:[self.wing photo].thumbUrl]];
    }
    else
    {
        //set placeholder
        cell.textLabel.text = NSLocalizedString(@"Select your Wing…", nil);
        
        //set text color
        cell.textLabel.textColor = [UIColor grayColor];
        
        //set image to placeholder image
        [imageView setImage:[UIImage imageNamed:@"wing-tablecell-placeholder.png"]];
    }
    
    // apply the mask
    [imageView applyMask:[UIImage imageNamed:@"wing-tablecell-item-mask.png"]];
    
    //add overlay
    UIImageView *overlay = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wing-tablecell-item-overlay.png"]] autorelease];
    [imageView addSubview:overlay];
    
    // add subview
    [cell.contentView addSubview:imageView];
}

- (void)updateDetailsCell:(DDTextViewTableViewCell*)cell
{
    //apply title
    cell.textView.text = self.details;
    
    //update delegate
    cell.textView.textView.delegate = self;

    //set placeholder
    cell.textView.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Enter your message to %@ & %@. Here is your chance to be unique and make a good first impression. You can only send one message until they reply, so make it a good one!", @"The variables are the activity creator and wing, respectively."), doubleDate.user.firstName, doubleDate.wing.firstName];
    
    cell.textView.textView.returnKeyType = UIReturnKeyDone;
}

- (NSIndexPath*)wingIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:0];
}

- (NSIndexPath*)detailsIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:1];
}

- (DDTextView*)textViewDetails
{
    return [(DDTextViewTableViewCell*)[self.tableView cellForRowAtIndexPath:[self detailsIndexPath]] textView];
}

#pragma mark -
#pragma mark API

#pragma mark -
#pragma mark DDAPIControllerDelegate

- (void)createEngagementSucceed:(DDEngagement*)engagement
{
    //hide hud
    [self hideHud:YES];
    
    //inform delegate
    [self.delegate sendEngagementViewControllerDidCreatedEngagement:engagement];
    
    // Only show dialog for Ghost users
    if ([[engagement.wing ghost] boolValue])
        [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                      message:NSLocalizedString(@"I'm interested in going on this DoubleDate and picked you to be my wing.", @"Facebook request dialog text to ghost user for send engagement")
                                                        title:NSLocalizedString(@"Tell Your Wing", @"Facebook dialog title in send enagement")
                                                        users:[NSArray arrayWithObject:engagement.wing]
                                                      handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                          if (error)
                                                          {
                                                              [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
                                                          }
                                                          else
                                                          {
                                                              if (result == FBWebDialogResultDialogNotCompleted)
                                                                  [DDStatisticsController trackEvent:DDStatisticsEventSentEngagementSkippedInviteGhost];
                                                              else
                                                                  [DDStatisticsController trackEvent:DDStatisticsEventSentEngagementDidInviteGhost];
                                                          }
                                                      }];
}

- (void)createEngagementDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textFieldTextDidChange:(NSNotification*)notification
{
}

- (void)textViewDidChange:(UITextView *)textView
{
    //update details
    self.details = [[self textViewDetails] text];
    
    //update navigation bar
    [self updateNavigationBar];
    
    //update left characters
    [self updateLeftCharacters];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        if ([[[self textViewDetails] textView] isFirstResponder])
            [[[self textViewDetails] textView] resignFirstResponder];
        return NO;
    }
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return newLength <= kMaxDetailsLength;
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

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    return [[self tableView:aTableView viewForHeaderInSection:section] frame].size.height;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return nil;
    
    return [self oldStyleViewForHeaderWithMainText:NSLocalizedString(@"Message", nil) detailedText:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:[self detailsIndexPath]] == NSOrderedSame)
        return 160;
    else if ([indexPath compare:[self wingIndexPath]] == NSOrderedSame)
        return 46;
    return [DDTableViewCell height];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check pressed cell
    if ([indexPath compare:[self wingIndexPath]] == NSOrderedSame)
    {
        //hide keyboard
        DDTextViewTableViewCell *textViewCell = (DDTextViewTableViewCell*)[aTableView cellForRowAtIndexPath:[self detailsIndexPath]];
        if ([textViewCell isKindOfClass:[DDTextFieldTableViewCell class]] && [textViewCell.textView.textView isFirstResponder])
            [textViewCell.textView.textView resignFirstResponder];
        
        //open view controller
        DDSelectFacebookFriendViewController *viewController = [[[DDSelectFacebookFriendViewController alloc] init] autorelease];
        viewController.delegate = self;
        viewController.excludeUsers = [NSArray arrayWithObjects:self.doubleDate.wing, self.doubleDate.user, nil];
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
    return 1;
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
        if ([indexPath compare:[self wingIndexPath]] == NSOrderedSame)
            cell = [[[DDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        //create text view table view cell
        else if ([indexPath compare:[self detailsIndexPath]] == NSOrderedSame)
            cell = [[[DDTextViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    //apply table view style
    [cell applyGroupedBackgroundStyleForTableView:aTableView withIndexPath:indexPath];
    
    //check index path
    if ([indexPath compare:[self wingIndexPath]] == NSOrderedSame)
        [self updateWingCell:cell];
    else if ([indexPath compare:[self detailsIndexPath]] == NSOrderedSame)
        [self updateDetailsCell:(DDTextViewTableViewCell*)cell];
    
    return cell;
}

#pragma mark -
#pragma mark DDSelectFacebookFriendViewControllerDelegate

- (void)selectFacebookFriendViewControllerDidSelectWing:(DDShortUser*)user
{
    //set wing
    self.wing = user;
    
    //increase activate keyboard code
    activateKeyboardCode_++;
    
    //update
    [self updateNavigationBar];
    
    //update the cell
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self wingIndexPath]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //pop view controller
    [self.navigationController popViewControllerAnimated:YES];
}

@end
