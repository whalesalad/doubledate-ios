//
//  DDFeedbackViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDFeedbackViewController.h"
#import "DDAuthenticationController.h"
#import "DDUser.h"
#import "DDBarButtonItem.h"
#import "DDTableViewController+Refresh.h"
#import "DDTextViewTableViewCell.h"
#import "DDTextView.h"
#import "DDTools.h"

@interface DDFeedbackViewController ()<UITextViewDelegate>
@end

@implementation DDFeedbackViewController

- (id)init
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set navigation title
    self.navigationItem.title = NSLocalizedString(@"Feedback", @"Feedback navigation title");
    
    //set left bar button
    self.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Cancel", nil) target:self action:@selector(cancelTouched)];
    
    //set right bar button
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Send", nil) target:self action:@selector(sendTouched)];
    
    //remove search bar
    self.tableView.tableHeaderView = nil;
    
    //remov refresh controler
    self.isRefreshControlEnabled = NO;
    
    //disable touch
    self.tableView.scrollEnabled = NO;
    
    //move table view to top
    self.tableView.contentInset = UIEdgeInsetsMake(-12, 0, 0, 0);
    
    //disable right button by default
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    DDTextViewTableViewCell *cell = (DDTextViewTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.textView.textView becomeFirstResponder];
}

- (void)cancelTouched
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendTouched
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Sending feedback...", @"Sending message of feedback page") animated:YES];
    
    //extract text view cell
    DDTextViewTableViewCell *cell = (DDTextViewTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    //trim feedback
    NSString *feedback = [cell.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    //send feedback
    [self.apiController sendFeedback:feedback];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    return [self tableView:aTableView viewForHeaderInSection:section].frame.size.height;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    return [self oldStyleViewForHeaderWithMainText:NSLocalizedString(@"Your Comments", @"Feedback title on feedback page") detailedText:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //21 is the line height
    if ([DDTools isiPhone5Device])
        return 21*10;
    return 21*6;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //create cell
    DDTextViewTableViewCell *cell = [[[DDTextViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        
    //apply styling for cell
    [cell applyGroupedBackgroundStyleForTableView:aTableView withIndexPath:indexPath];
    
    //set placeholder
    cell.textView.placeholder = [NSString stringWithFormat:NSLocalizedString(@"%@, your feedback will help us improve DoubleDate. What do you love? What do you hate?", @"Feedback placeholder"), [[DDAuthenticationController currentUser] firstName]];
    
    cell.textView.textView.delegate = self;
    
    //disable selection
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark API

- (void)sendFeedbackSucceed
{
    //hide hud
    [self hideHud:YES];
    
    //show succeed message
    NSString *message = NSLocalizedString(@"Thank You!", @"Thanks message after feedback sending");
    
    //show completed hud
    [self showCompletedHudWithText:message];
    
    //go back
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)sendFeedbackDidFailedWithError:(NSError *)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.navigationItem.rightBarButtonItem.enabled = [[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0;
}

@end
