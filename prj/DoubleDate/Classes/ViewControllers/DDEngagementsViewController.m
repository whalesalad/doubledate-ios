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

@implementation DDEngagementsViewController

@synthesize weakParentViewController;

@synthesize doubleDate;

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
    
    //add no incoming messages image view
    UIImageView *imageViewNoData = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no-incoming.png"]] autorelease];
    imageViewNoData.center = CGPointMake(self.viewNoData.center.x, self.viewNoData.center.y - 40);
    imageViewNoData.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.viewNoData addSubview:imageViewNoData];
    
    //add no messages label
    UILabel *labelNoData = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 60)] autorelease];
    labelNoData.center = CGPointMake(self.viewNoData.center.x, self.viewNoData.center.y + 70);
    labelNoData.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    labelNoData.numberOfLines = 2;
    labelNoData.text = NSLocalizedString(@"You haven't received any\nincoming messages yet.", nil);
    labelNoData.textAlignment = NSTextAlignmentCenter;
    labelNoData.backgroundColor = [UIColor clearColor];
    DD_F_NO_DATA_LABEL(labelNoData);
    [self.viewNoData addSubview:labelNoData];
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
    [doubleDate release];
    [engagements_ release];
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
    [self.apiController getEngagementsForDoubleDate:self.doubleDate];
}

#pragma mark -
#pragma mark API

- (void)getEngagementsForDoubleDateSucceed:(NSArray*)engagements
{
    //save engagements
    [engagements_ release];
    engagements_ = [[NSMutableArray alloc] initWithArray:engagements];
    
    //finish refresh
    [self finishRefresh];
    
    //reload data
    [self.tableView reloadData];
    
    //update no messages
    [self updateNoDataView];
}

- (void)getEngagementsForDoubleDateDidFailedWithError:(NSError*)error
{
    //unset engagements
    [engagements_ release];
    engagements_ = [[NSMutableArray alloc] init];
    
    //finish refresh
    [self finishRefresh];
        
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
    
    //add chat view controller
    DDChatViewController *chatViewController = [[[DDChatViewController alloc] init] autorelease];
    [chatViewController setDoubleDate:self.doubleDate];
    [chatViewController setEngagement:engagement];
    [chatViewController setWeakParentViewController:self.weakParentViewController];
    
    //push it
    [self.weakParentViewController.navigationController pushViewController:chatViewController animated:YES];
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
