//
//  DDSendEngagementViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 05.12.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDSendEngagementViewController.h"
#import "DDTableViewCell.h"
#import "DDTextViewTableViewCell.h"
#import "DDTools.h"
#import "DDButton.h"

@interface DDSendEngagementViewController ()

@end

@implementation DDSendEngagementViewController

@synthesize doubleDate;

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
    [self.buttonCancel applyBottomBarDesignWithTitle:self.buttonCancel.titleLabel.text icon:[UIImage imageNamed:@"button-icon-cancel.png"] background:[UIImage imageNamed:@"lower-button-pink.png"]];
    [self.buttonSend applyBottomBarDesignWithTitle:self.buttonSend.titleLabel.text icon:[UIImage imageNamed:@"button-icon-send.png"] background:[UIImage imageNamed:@"lower-button-blue.png"]];
    
    //hide back button
    self.navigationItem.leftBarButtonItem = nil;
    
    //add gesture recognizer
    UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)] autorelease];
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark other

- (IBAction)cancelTouched:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendTouched:(id)sender
{
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self tableView:tableView viewForHeaderInSection:section].frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self viewForHeaderWithMainText:NSLocalizedString(@"ADD A NOTE", nil) detailedText:NSLocalizedString(@"250 CHARACTERS REMAINING", nil)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 16;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (tableView.frame.size.height - 44 - 16);
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
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

@end
