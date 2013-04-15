//
//  DDSendEngagementViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDSendEngagementViewController.h"
#import "DDTools.h"
#import "DDShortUser.h"
#import "DDEngagement.h"
#import "DDTableViewCell.h"
#import "DDImageView.h"
#import "DDTextFieldTableViewCell.h"
#import "DDTextViewTableViewCell.h"
#import "DDTextField.h"
#import "DDTextView.h"
#import "DDAppDelegate+WingsMenu.h"
#import <QuartzCore/QuartzCore.h>

#define kMaxDetailsLength 250

@interface DDSendEngagementViewController () <UITextFieldDelegate, UITextViewDelegate, DDChooseWingViewDelegate>

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
    self.navigationItem.title = NSLocalizedString(@"Send a Message", nil);
    
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
        engagement.wingId = self.wing.identifier;
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
    self.labelLeftCharacters.text = [NSString stringWithFormat:@"%d/%d", [self.details length], kMaxDetailsLength];
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
        imageView.backgroundColor = [UIColor redColor];
        imageView.frame = CGRectMake(cell.contentView.frame.size.width - 76, 0, 76, 45);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [imageView applyMask:[UIImage imageNamed:@"wing-tablecell-item-mask.png"]];
        [cell.contentView addSubview:imageView];
        
        //add overlay
        UIImageView *overlay = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wing-tablecell-item-overlay.png"]] autorelease];
        [imageView addSubview:overlay];
                
        //update image view
        [imageView reloadFromUrl:[NSURL URLWithString:[self.wing photo].smallUrl]];
    }
    else
    {
        //set placeholder
        cell.textLabel.text = NSLocalizedString(@"Choose a Wing", nil);
        
        //set text color
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
    cell.textView.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Enter your message to %@ & %@. Here is your chance to be unique and make a good first impression.", @"The variables are the activity creator and wing, respectively."), doubleDate.user.firstName, doubleDate.wing.firstName];
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
    
    return [self oldStyleViewForHeaderWithMainText:NSLocalizedString(@"YOUR MESSAGE", nil) detailedText:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:[self detailsIndexPath]] == NSOrderedSame)
        return 160;
    else if ([indexPath compare:[self wingIndexPath]] == NSOrderedSame)
        return 45;
    return [DDTableViewCell height];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check pressed cell
    if ([indexPath compare:[self wingIndexPath]] == NSOrderedSame)
    {
        DDTextViewTableViewCell *textViewCell = (DDTextViewTableViewCell*)[aTableView cellForRowAtIndexPath:[self detailsIndexPath]];
        if ([textViewCell isKindOfClass:[DDTextFieldTableViewCell class]] && [textViewCell.textView.textView isFirstResponder])
            [textViewCell.textView.textView resignFirstResponder];
        [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] presentWingsMenuWithDelegate:self excludedUsers:[NSArray arrayWithObjects:self.doubleDate.wing, self.doubleDate.user, nil]];
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
