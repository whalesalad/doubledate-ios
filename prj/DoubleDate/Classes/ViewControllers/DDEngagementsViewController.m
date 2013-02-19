//
//  DDEngagementsViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 23.12.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDEngagementsViewController.h"
#import "DDDoubleDate.h"
#import "DDTableViewController+Refresh.h"
#import "DDEngagementTableViewCell.h"
#import "DDEngagement.h"
#import "DDChatViewController.h"
#import "DDShortUser.h"
#import "DDObjectsController.h"
#import "DDAuthenticationController.h"
#import "DDUser.h"
#import <QuartzCore/QuartzCore.h>

@implementation DDEngagementsViewController

@synthesize weakParentViewController;

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
    
    //remove search bar
    self.tableView.tableHeaderView = nil;
    
    // Add slight padding to end of view.
    self.tableView.contentInset = UIEdgeInsetsMake(0,0,3,0);
    
    //add navigation title
    self.navigationItem.title = NSLocalizedString(@"Messages", nil);
    
    //add no incoming messages image view
    UIImageView *imageViewNoData = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no-incoming.png"]] autorelease];
    imageViewNoData.center = CGPointMake(self.viewNoData.center.x, self.viewNoData.center.y - 50);
    imageViewNoData.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.viewNoData addSubview:imageViewNoData];
    
    //add no messages label
    UILabel *labelNoData = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 60)] autorelease];
    labelNoData.center = CGPointMake(self.viewNoData.center.x, self.viewNoData.center.y + 60);
    labelNoData.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    labelNoData.numberOfLines = 2;
    labelNoData.text = NSLocalizedString(@"Chat messages with other\nDoubleDaters will appear here", nil);
    labelNoData.textAlignment = NSTextAlignmentCenter;
    labelNoData.backgroundColor = [UIColor clearColor];
    
    // no data label style
    [self applyNoDataLabelStyle:labelNoData];
    
    [self.viewNoData addSubview:labelNoData];
}

- (void)applyNoDataLabelStyle:(UILabel*)label {
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    label.textColor = [UIColor colorWithRed:93.0f/255.0f green:93.0f/255.0f blue:93.0f/255.0f alpha:1.0];
    label.layer.shadowOffset = CGSizeMake(0, 1);
    label.layer.shadowOpacity = 1.0f;
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowRadius = 1;
    label.layer.masksToBounds = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //reload the table as we updated the number unread messages
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check if we need to make a request
    if (!engagements_)
        [self startRefreshWithText:NSLocalizedString(@"Loading", nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [engagements_ release];
    [selectedEngagement_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark -

- (void)onRefresh
{
    //unset old values
    [engagements_ release];
    engagements_ = nil;
    
    //request friends
    [self.apiController getEngagements];
}

#pragma mark -
#pragma mark API

- (void)getEngagementsDateSucceed:(NSArray*)engagements
{
    //save engagements
    [engagements_ release];
    engagements_ = [[NSMutableArray alloc] initWithArray:engagements];
    
    //unset number of unread wings
    [DDAuthenticationController currentUser].unreadMessagesCount = [NSNumber numberWithInt:0];
    
    //finish refresh
    [self finishRefresh];
    
    //reload data
    [self.tableView reloadData];
    
    //update no messages
    [self updateNoDataView];
}

- (void)getEngagementsDateDidFailedWithError:(NSError*)error
{
    //unset engagements
    [engagements_ release];
    engagements_ = [[NSMutableArray alloc] init];
    
    //finish refresh
    [self finishRefresh];
        
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)getDoubleDateSucceed:(DDDoubleDate*)doubleDate
{
    //hide hud
    [self hideHud:YES];
    
    //check if we got needed doubledate
    if ([selectedEngagement_.activityId intValue] == [doubleDate.identifier intValue])
    {
        //unset unread count
        selectedEngagement_.unreadCount = [NSNumber numberWithInt:0];
        
        //add chat view controller
        DDChatViewController *chatViewController = [[[DDChatViewController alloc] init] autorelease];
        [chatViewController setDoubleDate:doubleDate];
        [chatViewController setEngagement:selectedEngagement_];
        [chatViewController setWeakParentViewController:self.weakParentViewController];
        
        //push it
        [self.weakParentViewController.navigationController pushViewController:chatViewController animated:YES];
    }
}

- (void)getDoubleDateDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DDEngagementTableViewCell height];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //save engagement
    DDEngagement *engagement = [engagements_ objectAtIndex:indexPath.row];
    
    //save selected engagement
    [selectedEngagement_ release];
    selectedEngagement_ = [engagement retain];
    
    //show hud
    [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
    
    //request doubledate
    DDDoubleDate *doubleDate = [[[DDDoubleDate alloc] init] autorelease];
    doubleDate.identifier = selectedEngagement_.activityId;
    [self.apiController getDoubleDate:doubleDate];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [engagements_ count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set identifier
    NSString *cellIdentifier = [[DDEngagementTableViewCell class] description];
    
    //create cell if needed
    DDEngagementTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[[UINib nibWithNibName:cellIdentifier bundle:nil] instantiateWithOwner:aTableView options:nil] objectAtIndex:0];
    
    //save data
    [cell setEngagement:[engagements_ objectAtIndex:indexPath.row]];
    
    //update layouts
    [cell setNeedsLayout];
    
    return cell;
}

@end
