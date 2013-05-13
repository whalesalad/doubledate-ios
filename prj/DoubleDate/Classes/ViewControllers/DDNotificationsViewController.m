//
//  DDNotificationsViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 08.10.12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
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
#import "DDAPIObject.h"
#import "DDDialogAlertView.h"
#import "DDDialog.h"
#import "DDImage.h"
#import "DDTools.h"
#import "UIView+Other.h"

@interface DDNotificationsViewController () <UITableViewDataSource, UITableViewDelegate, DDDialogAlertViewDelegate>

@property(nonatomic, retain) DDEngagement *selectedEngagement;
@property(nonatomic, retain) DDNotification *selectedNotification;

@property(nonatomic, retain) NSString *lastReadCallbackNotificationId;

- (void)onDataRefreshed;
- (NSArray*)notifications;
- (void)markNotificationAsSelected:(DDNotification*)notification;

@end

@implementation DDNotificationsViewController

@synthesize selectedEngagement;
@synthesize selectedNotification;
@synthesize lastReadCallbackNotificationId;

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

- (void)customizeNoDataView
{
    [self.viewNoData applyNoDataWithMainText:NSLocalizedString(@"You don't have any notifications.", @"Notifications no data main text.")
                                    infoText:NSLocalizedString(@"Add wings, create some dates,\n let's get this party started!", @"Notifications no data detail text.")];
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
    
    //customize no data view
    [self customizeNoDataView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //reload the table as we updated the number unread messages
    [self.tableView reloadData];
    
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
    [lastReadCallbackNotificationId release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (void)updateBadge
{
    //update current user
    NSInteger unreadNotificationsCount = 0;
    for (DDNotification *n in notifications_)
    {
        if ([[n unread] boolValue])
            unreadNotificationsCount++;
    }
    [DDAuthenticationController currentUser].unreadNotificationsCount = [NSNumber numberWithInt:unreadNotificationsCount];
    [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] updateApplicationBadge];
}

- (void)markNotificationAsSelected:(DDNotification*)notification
{
    //check if unread
    if ([[notification unread] boolValue])
    {
        //mark as read
        notification.unread = [NSNumber numberWithBool:NO];
        
        //update badge
        [self updateBadge];
        
        //make api call
        DDNotification *notificationToSend = [[[DDNotification alloc] init] autorelease];
        notificationToSend.identifier = [notification identifier];
        [self.apiController getNotification:notificationToSend];
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
    
    //check for dialog
    if ([self.selectedNotification dialog])
    {
        //present dialog
        DDDialogAlertView *alertView = [[[DDDialogAlertView alloc] initWithDialog:[self.selectedNotification dialog]] autorelease];
        alertView.dialogDelegate = self;

        alertView.imageUrl = [NSURL URLWithString:self.selectedNotification.photo.squareUrl];
        [alertView show];
        
        //mark notification as read
        [self markNotificationAsSelected:self.selectedNotification];
        
        //reload the table
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if ([self.selectedNotification callbackUrl])
    {
        DDAPNSPayload *payload = [[[DDAPNSPayload alloc] init] autorelease];
        payload.callbackUrl = [self.selectedNotification callbackUrl];
        payload.notificationId = [self.selectedNotification identifier];
        payload.hasDialog = self.selectedNotification.dialog?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
        [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] handleNotificationPayload:payload];
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
    
    //mark notification from apns as read
    for (DDNotification *notification in notifications_)
    {
        if (self.lastReadCallbackNotificationId && ([notification.identifier intValue] == [self.lastReadCallbackNotificationId intValue]))
            [self markNotificationAsSelected:notification];
    }
    
    //update badge number
    [self updateBadge];
    
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
        self.lastReadCallbackNotificationId = [DDAPIObject stringForObject:[(NSDictionary*)[notification object] objectForKey:APNS_NOTIFICATION_ID_KEY]];
    
    //just refresh
    [self onRefresh];
}

- (void)appDelegateAPNSWillOpenCallbackUrlNotification:(NSNotification*)notification
{
    //get needed notification
    DDAPNSPayload *payload = [notification object];
    DDNotification *notificationToApply = nil;
    for (DDNotification *n in notifications_)
    {
        if (payload.notificationId && ([payload.notificationId intValue] == [[n identifier] intValue]))
            notificationToApply = n;
    }
    
    //apply
    [self markNotificationAsSelected:notificationToApply];
}

#pragma mark DDDialogAlertViewDelegate

- (void)dialogAlertViewDidConfirm:(DDDialogAlertView*)alertView
{
    //send post on confirmation url
    if (alertView.dialog.confirmUrl)
    {
        //create request
        NSString *requestPath = [[DDTools authUrlPath] stringByAppendingPathComponent:alertView.dialog.confirmUrl];
        RKRequest *request = [[[RKRequest alloc] initWithURL:[NSURL URLWithString:requestPath]] autorelease];
        request.method = RKRequestMethodPOST;
        NSArray *keys = [NSArray arrayWithObjects:@"Accept", @"Content-Type", @"Authorization", nil];
        NSArray *objects = [NSArray arrayWithObjects:@"application/json", @"application/json", [NSString stringWithFormat:@"Token token=%@", [DDAuthenticationController token]], nil];
        request.additionalHTTPHeaders = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        //send request
        [[DDRequestsController sharedDummyController] startRequest:request];
    }
    
    //remove notification from the list
    [notifications_ removeObject:self.selectedNotification];
    
    //reload the table
    [self.tableView reloadData];
    
    //update no data view
    [self updateNoDataView];
    
    //unset selected notification
    self.selectedNotification = nil;
}

- (void)dialogAlertViewDidCancel:(DDDialogAlertView*)alertView
{
    
}

@end
