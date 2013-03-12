//
//  DDChooseWingView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDChooseWingView.h"
#import "DDDoubleDate.h"
#import "DDAPIController.h"
#import "DDChooseWingTableViewCell.h"
#import "DDTools.h"
#import <QuartzCore/QuartzCore.h>

@interface DDChooseWingView ()<DDAPIControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *loading;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewBackground;

@end

@implementation DDChooseWingView

@synthesize buttonFullscreen;

@synthesize loading;
@synthesize tableView;
@synthesize imageViewBackground;

@synthesize delegate;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)initSelf
{
    //add api controller
    apiController_ = [[DDAPIController alloc] init];
    apiController_.delegate = self;
    
    self.imageViewBackground.image = [DDTools resizableImageFromImage:self.imageViewBackground.image];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initSelf];
    }
    return self;
}

- (void)start
{
    //start loading
    [self.loading startAnimating];
    
    //hide table view
    self.tableView.hidden = YES;
    
    //request friends
    [apiController_ getFriends];
}

- (void)dealloc
{
    apiController_.delegate = nil;
    [apiController_ release];
    [buttonFullscreen release];
    [loading release];
    [tableView release];
    [imageViewBackground release];
    [friends_ release];
    [super dealloc];
}

#pragma mark api

- (void)getFriendsSucceed:(NSArray*)friends
{
    //save friends
    [friends_ release];
    friends_ = [friends retain];
    
    //show table view
    self.tableView.hidden = NO;
    
    //reload table view
    [self.tableView reloadData];
    
    //stop loading
    [self.loading stopAnimating];
}

- (void)getFriendsDidFailedWithError:(NSError*)error
{
    //stop loading
    [self.loading stopAnimating];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DDChooseWingTableViewCell height];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDChooseWingTableViewCell *tableViewCell = (DDChooseWingTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath];
    [self.delegate chooseWingViewDidSelectUser:tableViewCell.shortUser];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [friends_ count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set cell identifier
    NSString *cellIdentifier = NSStringFromClass([DDChooseWingTableViewCell class]);
    
    //create cell if needed
    DDChooseWingTableViewCell *tableViewCell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!tableViewCell)
    {
        tableViewCell = [[[UINib nibWithNibName:cellIdentifier bundle:nil] instantiateWithOwner:aTableView options:nil] objectAtIndex:0];
    }
    
    //set user
    [tableViewCell setShortUser:[friends_ objectAtIndex:indexPath.row]];
    
    return tableViewCell;
}

@end
