//
//  DDPurchaseViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 03.03.13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDPurchaseViewController.h"
#import "DDCoinsBar.h"
#import "DDAuthenticationController.h"
#import "DDUser.h"
#import "DDInAppProductTableViewCell.h"

@interface DDPurchaseViewController ()

@property(nonatomic, readonly) DDCoinsBar *coinsBar;

@end

@implementation DDPurchaseViewController

@synthesize products;
@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //register cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DDInAppProductTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DDInAppProductTableViewCell class])];
    
    //set coins bar as table view header
    self.tableView.tableHeaderView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DDCoinsBar class]) owner:self options:nil] objectAtIndex:0];
    
    //set coins bar right button
    [self.coinsBar setButtonTitle:NSLocalizedString(@"Close", nil)];
    
    //set coins close handler
    [self.coinsBar addTarget:self action:@selector(closeTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    //set coins bar title
    [self.coinsBar setValue:[[[DDAuthenticationController currentUser] totalCoins] intValue]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //hide navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)dealloc
{
    [products release];
    [tableView release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (DDCoinsBar*)coinsBar
{
    return (DDCoinsBar*)self.tableView.tableHeaderView;
}

- (void)closeTouched:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)customizeTitleTableViewCell:(UITableViewCell*)tableViewCell
{
    UITextView *textView = [[[UITextView alloc] initWithFrame:tableViewCell.bounds] autorelease];
    textView.userInteractionEnabled = NO;
    textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    textView.backgroundColor = [UIColor clearColor];
    textView.text = NSLocalizedString(@"Coins let you unlock upgrades and respond to incoming messages.", nil);
    textView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    textView.textColor = [UIColor whiteColor];
    [tableViewCell.contentView addSubview:textView];
}

- (void)customizeDescriptionTableViewCell:(UITableViewCell*)tableViewCell
{
    UITextView *textView = [[[UITextView alloc] initWithFrame:tableViewCell.bounds] autorelease];
    textView.userInteractionEnabled = NO;
    textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    textView.backgroundColor = [UIColor clearColor];
    textView.text = NSLocalizedString(@"Coins never expire and we'll never automatically charge you for more.", nil);
    textView.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    textView.textColor = [UIColor whiteColor];
    [tableViewCell.contentView addSubview:textView];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForFooterInSection:(NSInteger)section
{
    return FLT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return FLT_MIN;
    else if (section == 1)
        return FLT_MIN;
    else if (section == 2)
        return 40;
    return FLT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 2)
    {
#warning I cannot seem to move this label inward to align with the other text blocks. It needs to be pushed +20 from the left, I think.
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)] autorelease];
        label.text = [NSLocalizedString(@"Choose a Package Below", nil) uppercaseString];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        return label;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return 55;
    else if (indexPath.section == 1)
        return 60;
    else if (indexPath.section == 2)
        return [DDInAppProductTableViewCell height];
    return 0;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else if (section == 1)
        return 1;
    else if (section == 2)
        return [self.products count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check in-app section
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        [self customizeTitleTableViewCell:cell];
        return cell;
    }
    else if (indexPath.section == 1)
    {
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        [self customizeDescriptionTableViewCell:cell];
        return cell;
    }
    else if (indexPath.section == 2)
    {
        //set identifier
        NSString *cellIdentifier = NSStringFromClass([DDInAppProductTableViewCell class]);
        assert(cellIdentifier);
        
        //create cell if needed
        DDInAppProductTableViewCell *tableViewCell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!tableViewCell)
        {
            tableViewCell = [[[UINib nibWithNibName:cellIdentifier bundle:nil] instantiateWithOwner:aTableView options:nil] objectAtIndex:0];
        }
        
        //customize background style
        [tableViewCell applyGroupedBackgroundStyleForTableView:aTableView withIndexPath:indexPath];
        
        //apply value
        tableViewCell.labelAmount.text = [NSString stringWithFormat:@"%d", indexPath.row * 1000];
        tableViewCell.labelCost.text = @"$0.99";
        
        return tableViewCell;
    }
    
    return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
}

@end
