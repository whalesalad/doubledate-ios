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

@interface DDEngagementsViewController ()

@end

@implementation DDEngagementsViewController

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
        cell = [[[DDEngagementTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    
    //set accessory view
    cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grey-detail-arrow.png"]] autorelease];
    
    //save data
    [cell setEngagement:[engagements_ objectAtIndex:indexPath.row]];
    
    //update layouts
    [cell setNeedsLayout];
    
    return cell;
}

@end
