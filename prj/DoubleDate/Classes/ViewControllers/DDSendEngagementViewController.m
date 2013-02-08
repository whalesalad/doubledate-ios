//
//  DDSendEngagementViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 05.12.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDSendEngagementViewController.h"
#import "DDLocationTableViewCell.h"
#import "DDDoubleDate.h"
#import "DDTableViewCell.h"
#import "DDTextViewTableViewCell.h"
#import "DDTools.h"
#import "DDButton.h"
#import "DDShortUser.h"
#import "DDEngagement.h"
#import "DDTextView.h"

@interface DDSendEngagementViewController () <DDSelectWingViewDelegate>

- (void)updateSendButton;

@end

@implementation DDSendEngagementViewController

@synthesize doubleDate;

@synthesize tableView;

@synthesize selectWingView;

@synthesize buttonCancel;
@synthesize buttonSend;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.moveWithKeyboard = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //customize button
    [self.buttonCancel applyBottomBarDesignWithTitle:self.buttonCancel.titleLabel.text icon:[UIImage imageNamed:@"button-icon-cancel.png"] background:[UIImage imageNamed:@"lower-button-gray.png"]];
    [self.buttonSend applyBottomBarDesignWithTitle:self.buttonSend.titleLabel.text icon:[UIImage imageNamed:@"button-icon-send.png"] background:[UIImage imageNamed:@"lower-button-blue.png"]];
    
    //hide back button
    self.navigationItem.leftBarButtonItem = nil;
    
    //set navigation title
    self.navigationItem.titleView = [self viewForNavigationBarWithMainText:[NSString stringWithFormat:NSLocalizedString(@"DoubleDate %@ & %@", nil), doubleDate.user.firstName, doubleDate.wing.firstName] detailedText:[DDLocationTableViewCell detailedTitleForLocation:self.doubleDate.location]];
    
    //add gesture recognizer
    UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)] autorelease];
    [self.view addGestureRecognizer:tapRecognizer];
    
    //set selecting view
    self.selectWingView.doubleDate = self.doubleDate;
    self.selectWingView.delegate = self;
    [self.selectWingView start];
    
    
    //update send button
    [self updateSendButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [doubleDate release];
    [tableView release];
    [selectWingView release];
    [buttonCancel release];
    [buttonSend release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (IBAction)cancelTouched:(id)sender
{
    [self.delegate sendEngagementViewControllerDidCancel];
}

- (IBAction)sendTouched:(id)sender
{
    //check for wing
    if (self.selectWingView.wing)
    {
        //show loading
        [self showHudWithText:NSLocalizedString(@"Creating", nil) animated:YES];
        
        //request api
        DDEngagement *engagement = [[[DDEngagement alloc] init] autorelease];
        engagement.activityId = self.doubleDate.identifier;
        engagement.wingId = self.selectWingView.wing.identifier;
        engagement.message = [[(DDTextViewTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] textView] text];
        [self.apiController createEngagement:engagement];
    }
}

- (void)updateSendButton
{
    self.buttonSend.enabled = self.selectWingView.wing != nil;
}

#pragma mark -
#pragma mark touch

- (void)checkAndDismissResponderForView:(UIView*)v
{
    if ([v isFirstResponder])
        [v resignFirstResponder];
    for (UIView *c in [v subviews])
        [self checkAndDismissResponderForView:c];
}

- (void)tap:(UIGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (![sender.view isFirstResponder])
            [self checkAndDismissResponderForView:self.view];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    return [self tableView:aTableView viewForHeaderInSection:section].frame.size.height;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    return [self oldStyleViewForHeaderWithMainText:NSLocalizedString(@"ADD A NOTE", nil) detailedText:NSLocalizedString(@"250 CHARACTERS REMAINING", nil)];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForFooterInSection:(NSInteger)section
{
    return 16;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (aTableView.frame.size.height - 44 - 16);
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
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
    DDTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        //create text view
        cell = [[[DDTextViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    //apply table view style
    [cell applyGroupedBackgroundStyleForTableView:aTableView withIndexPath:indexPath];
    
    return cell;
}

#pragma mark -
#pragma mark DDSelectWingViewDelegate

- (void)selectWingViewDidSelectWing:(id)sender
{
    [self updateSendButton];
}

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

@end
