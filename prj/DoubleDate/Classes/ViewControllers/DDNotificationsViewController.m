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
#import "DDEngagement.h"
#import "DDDoubleDate.h"
#import "DDNotificationTableViewCell.h"
#import "DDNotification.h"
#import "DDMeViewController.h"
#import "DDDoubleDateViewController.h"
#import "DDChatViewController.h"
#import "DDAppDelegate+APNS.h"

@interface DDNotificationsViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, retain) DDEngagement *selectedEngagement;
@property(nonatomic, retain) DDNotification *selectedNotification;

@property(nonatomic, retain) NSString *lastReadCallbackUrl;

- (void)onDataRefreshed;
- (NSArray*)notifications;
- (void)markNotificationAsSelected:(DDNotification*)notification;

@end

@implementation DDNotificationsViewController

@synthesize selectedEngagement;
@synthesize selectedNotification;
@synthesize lastReadCallbackUrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.cellsIdentifiers = [NSDictionary dictionaryWithObject:NSStringFromClass([DDNotificationTableViewCell class]) forKey:NSStringFromClass([DDNotificationTableViewCell class])];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDelegateAPNSDidReceiveRemoteNotification:) name:DDAppDelegateAPNSDidReceiveRemoteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDelegateAPNSWillOpenCallbackUrlNotification:) name:DDAppDelegateAPNSWillOpenCallbackUrlNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Notifications", nil);
    
    // Remove search
    self.tableView.tableHeaderView = nil;
    
    // Push the table view down slightly to make sides and top even.
    self.tableView.contentInset = UIEdgeInsetsMake(2,0,0,0);
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
    [selectedEngagement release];
    [selectedNotification release];
    [lastReadCallbackUrl release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (void)markNotificationAsSelected:(DDNotification*)notification
{
    //check if unread
    if ([[notification unread] boolValue])
    {
        //mark as read
        notification.unread = [NSNumber numberWithBool:NO];
        
        //make api call
        DDNotification *notificationToSend = [[[DDNotification alloc] init] autorelease];
        notificationToSend.identifier = [notification identifier];
        [self.apiController getNotification:notificationToSend];
        
        //update current user
        NSInteger unreadNotificationsCount = 0;
        for (DDNotification *n in notifications_)
        {
            if ([[n unread] boolValue])
                unreadNotificationsCount++;
        }
        [DDAuthenticationController currentUser].unreadNotificationsCount = [NSNumber numberWithInt:unreadNotificationsCount];
    }
}

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
    //save selected notification
    self.selectedNotification = [[self notifications] objectAtIndex:indexPath.row];
    
    //check api path
    if ([self.selectedNotification callbackUrl])
        [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] handleNotificationUrl:[self.selectedNotification callbackUrl]];
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
    
    //mark notification from apns as read
    for (DDNotification *notification in notifications_)
    {
        if (self.lastReadCallbackUrl && [notification.callbackUrl isEqualToString:self.lastReadCallbackUrl])
            [self markNotificationAsSelected:notification];
    }
    
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

#pragma mark -
#pragma mark -

- (void)onRefresh
{
    //request notifications
    notificationsRequest_ = [self.apiController getNotifications];
}

- (void)appDelegateAPNSDidReceiveRemoteNotification:(NSNotification*)notification
{
    //save last read callback
    if ([[notification object] isKindOfClass:[NSDictionary class]])
        self.lastReadCallbackUrl = [(NSDictionary*)[notification object] objectForKey:@"callback_url"];
    
    //just refresh
    [self onRefresh];
}

- (void)appDelegateAPNSWillOpenCallbackUrlNotification:(NSNotification*)notification
{
    //get needed notification
    NSString *notificationCallbackUrl = [notification object];
    DDNotification *notificationToApply = nil;
    for (DDNotification *n in notifications_)
    {
        if (notificationCallbackUrl && [[n callbackUrl] isEqualToString:notificationCallbackUrl])
            notificationToApply = n;
    }
    
    //apply
    [self markNotificationAsSelected:notificationToApply];
}

@end
