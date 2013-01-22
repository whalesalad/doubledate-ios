//
//  DDChatViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 1/17/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDChatViewController.h"
#import "DDChatTableViewCell.h"
#import "DDDoubleDate.h"
#import "DDEngagement.h"
#import "DDMessage.h"
#import <QuartzCore/QuartzCore.h>

@interface DDChatViewController ()<UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@end

@implementation DDChatViewController

@synthesize parentViewController;

@synthesize doubleDate;
@synthesize engagement;

@synthesize mainView;
@synthesize topBarView;
@synthesize bottomBarView;
@synthesize textViewInput;
@synthesize buttonSend;
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChangeNotification:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //don't show layer under the status bar
    self.view.layer.masksToBounds = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check if we need to make a request
    if (!messages_)
        [self.apiController getMessagesForEngagement:self.engagement forDoubleDate:self.doubleDate];
}

#pragma mark -
#pragma mark Keyboard

- (void)keyboardDidShow:(NSNotification*)notification
{
    //save keyboard
    keyboardExist_ = YES;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    //scroll table view to bottom
    if ([messages_ count] > 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messages_ count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    //animate
    [UIView beginAnimations:@"DDChatViewControllerKeyboardAnimation" context:nil];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    CGRect rect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat dh = rect.size.height - self.weakParentViewController.tabBarController.tabBar.frame.size.height;
    self.mainView.frame = CGRectMake(self.mainView.frame.origin.x, self.mainView.frame.origin.y-dh, self.mainView.frame.size.width, self.mainView.frame.size.height);
    [UIView commitAnimations];
}

- (void)keyboardDidHide:(NSNotification*)notification
{
    //save keyboard
    keyboardExist_ = NO;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    //animate
    [UIView beginAnimations:@"DDChatViewControllerKeyboardAnimation" context:nil];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    CGRect rect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat dh = rect.size.height - self.weakParentViewController.tabBarController.tabBar.frame.size.height;
    self.mainView.frame = CGRectMake(self.mainView.frame.origin.x, self.mainView.frame.origin.y+dh, self.mainView.frame.size.width, self.mainView.frame.size.height);
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [messages_ release];
    [doubleDate release];
    [engagement release];
    [mainView release];
    [topBarView release];
    [bottomBarView release];
    [textViewInput release];
    [buttonSend release];
    [tableView release];
    [super dealloc];
}

#pragma mark -
#pragma mark IB

- (IBAction)sendTouched:(id)sender
{
    //send message
    if ([self.textViewInput.text length])
    {
        DDMessage *message = [[[DDMessage alloc] init] autorelease];
        message.message = self.textViewInput.text;
        [self.apiController createMessage:message forEngagement:self.engagement forDoubleDate:self.doubleDate];
    }
    
    //unset text
    self.textViewInput.text = nil;
    
    //hide keyboard
    [self.textViewInput resignFirstResponder];
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewTextDidChangeNotification:(NSNotification *)notification
{
    //check sender
    if ([notification object] != self.textViewInput)
        return;
    
    //save needed values
    CGSize sizeBefore = self.textViewInput.frame.size;
    CGSize sizeAfter = self.textViewInput.contentSize;
    
    //save maximal value
    CGFloat maximalHeight = self.bottomBarView.frame.origin.y + self.bottomBarView.frame.size.height - (self.topBarView.frame.origin.y + self.topBarView.frame.size.height) + self.mainView.frame.origin.y + 38;
    
    //check for maximal size
    sizeAfter = CGSizeMake(sizeAfter.width, MIN(sizeAfter.height, maximalHeight));
    
    //calculate frame change
    CGSize sizeChange = CGSizeMake(sizeAfter.width - sizeBefore.width, sizeAfter.height - sizeBefore.height);
    
    //change frame
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x - sizeChange.width, self.tableView.frame.origin.y - sizeChange.height, self.tableView.frame.size.width + sizeChange.width, self.tableView.frame.size.height);
    self.bottomBarView.frame = CGRectMake(self.bottomBarView.frame.origin.x - sizeChange.width, self.bottomBarView.frame.origin.y - sizeChange.height, bottomBarView.frame.size.width + sizeChange.width, bottomBarView.frame.size.height + sizeChange.height);
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DDChatTableViewCell heightForText:[(DDMessage*)[messages_ objectAtIndex:indexPath.row] message]];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat heightOfVisibleTableView = self.mainView.frame.origin.y + self.mainView.frame.size.height - self.bottomBarView.frame.size.height;
    CGFloat offsetFromBottom = self.tableView.contentSize.height - self.tableView.contentOffset.y - self.tableView.frame.size.height;
    if (keyboardExist_ && offsetFromBottom > heightOfVisibleTableView)
        [self.textViewInput resignFirstResponder];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [messages_ count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set identifier
    NSString *cellIdentifier = NSStringFromClass([DDChatTableViewCell class]);
    
    //create cell if needed
    DDChatTableViewCell *tableViewCell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!tableViewCell)
    {
        tableViewCell = [[[UINib nibWithNibName:cellIdentifier bundle:nil] instantiateWithOwner:aTableView options:nil] objectAtIndex:0];
    }
    tableViewCell.message = (DDMessage*)[messages_ objectAtIndex:indexPath.row];
    return tableViewCell;
}

#pragma mark -
#pragma mark API

- (void)getMessagesForEngagementSucceed:(NSArray*)messages
{
    //reload messages
    [messages_ release];
    messages_ = [[NSMutableArray alloc] initWithArray:messages];
    
    //reload the table
    [self.tableView reloadData];
}

- (void)getMessagesForEngagementDidFailedWithError:(NSError*)error
{
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)createMessageSucceed:(DDMessage*)message
{
    //reload messages
    [messages_ addObject:message];
    
    //reload the table
    [self.tableView reloadData];
}

- (void)createMessageDidFailedWithError:(NSError*)error
{
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
