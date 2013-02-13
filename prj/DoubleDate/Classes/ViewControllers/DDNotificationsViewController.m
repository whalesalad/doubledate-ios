//
//  DDNotificationsViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 08.10.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDNotificationsViewController.h"
#import "UIViewController+Extensions.h"
#import "DDTableViewController+Refresh.h"
#import "DDAuthenticationController.h"
#import "DDUser.h"
#import "DDNotificationTableViewCell.h"
#import "DDNotification.h"

@interface DDNotificationsViewController () <UITableViewDataSource, UITableViewDelegate>

- (void)onDataRefreshed;
- (NSArray*)notifications;

@end

@implementation DDNotificationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.cellsIdentifiers = [NSDictionary dictionaryWithObject:NSStringFromClass([DDNotificationTableViewCell class]) forKey:NSStringFromClass([DDNotificationTableViewCell class])];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Notifications", nil);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check if we need to make a request
    if (!notifications_)
        [self startRefreshWithText:NSLocalizedString(@"Loading", nil)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [notifications_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (NSArray*)notifications
{
    NSMutableArray *ret = [NSMutableArray array];
    for (DDNotification *notification in notifications_)
    {
        BOOL existInSearch = [self.searchTerm length] == 0;
        if (self.searchTerm)
        {
            if (notification.notification && [notification.notification rangeOfString:self.searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)
                existInSearch = YES;
        }
        if (existInSearch)
            [ret addObject:notification];
    }
    return ret;
}

- (void)onDataRefreshed
{
    //check both data received
    if (![self.apiController isRequestExist:notificationsRequest_])
    {
        //hide loading
        [self finishRefresh];
        
        //reload the table
        [self.tableView reloadData];
        
        //update no messages
        [self updateNoDataView];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DDNotificationTableViewCell heightForNotification:[[self notifications] objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //save notification
    DDNotification *notification = [[self notifications] objectAtIndex:indexPath.row];
    
    //check api path
    if ([notification callbackUrl])
    {
        //show hud
        [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
        
        //make api request
        NSString *path = [notification callbackUrl];
        path = [path stringByReplacingOccurrencesOfString:@"dbld8://" withString:@""];
        DDAPIControllerMethodType requestType = -1;
        if ([path rangeOfString:@"wings"].location != NSNotFound)
            requestType = DDAPIControllerMethodTypeGetUser;
        assert(requestType != -1);
        [self.apiController requestForPath:path withMethod:RKRequestMethodGET ofType:requestType];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [[self notifications] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set identifier
    NSString *cellIdentifier = NSStringFromClass([DDNotificationTableViewCell class]);
    
    //create cell if needed
    DDNotificationTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[[UINib nibWithNibName:cellIdentifier bundle:nil] instantiateWithOwner:aTableView options:nil] objectAtIndex:0];
    
    //save data
    [cell setNotification:[[self notifications] objectAtIndex:indexPath.row]];
    
    //update layouts
    [cell setNeedsLayout];
    
    return cell;
}

#pragma mark -
#pragma mark API

- (void)getNotificationsSucceed:(NSArray*)notifications
{
    //save notifications
    [notifications_ release];
    notifications_ = [[NSMutableArray arrayWithArray:notifications] retain];
    
    //unset number of unread wings
    [DDAuthenticationController currentUser].unreadNotificationsCount = [NSNumber numberWithInt:0];
    
    //inform about reloaded data
    [self performSelector:@selector(onDataRefreshed) withObject:nil afterDelay:0];
}

- (void)getNotificationsDidFailedWithError:(NSError*)error
{
    //save notifications
    [notifications_ release];
    notifications_ = [[NSMutableArray alloc] init];
    
    //inform about reloaded data
    [self performSelector:@selector(onDataRefreshed) withObject:nil afterDelay:0];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)requestDidSucceed:(NSObject*)object
{
    //hide hud
    [self hideHud:YES];
}

- (void)requestDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma mark -

- (void)onRefresh
{
    //request notifications
    notificationsRequest_ = [self.apiController getNotifications];
}

@end
