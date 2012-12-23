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
    //save friends
    [engagements_ release];
    engagements_ = [[NSMutableArray alloc] initWithArray:engagements];
    
    //finish refresh
    [self finishRefresh];
    
    //reload data
    [self.tableView reloadData];
}

- (void)getEngagementsForDoubleDateDidFailedWithError:(NSError*)error
{
    //finish refresh
    [self finishRefresh];
    
    //save friends
    [engagements_ release];
    engagements_ = [[NSMutableArray alloc] init];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
