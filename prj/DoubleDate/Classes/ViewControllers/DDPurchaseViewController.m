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
#import "DDInAppProduct.h"
#import "DDStoreKitController.h"
#import "DDObjectsController.h"
#import <QuartzCore/QuartzCore.h>

@interface DDPurchaseViewController ()<DDStoreKitControllerDelegate>

@property(nonatomic, readonly) DDCoinsBar *coinsBar;

@end

@implementation DDPurchaseViewController

@synthesize products;
@synthesize viewCoinsContainer;
@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //register cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DDInAppProductTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DDInAppProductTableViewCell class])];
    
    //set coins bar as table view header
    [self.viewCoinsContainer addSubview:[[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DDCoinsBar class]) owner:self options:nil] objectAtIndex:0]];
    
    //set coins bar right button
    [self.coinsBar setButtonTitle:NSLocalizedString(@"Close", nil)];
    
    self.coinsBar.layer.shadowOffset = CGSizeMake(0, 1);
    self.coinsBar.layer.shadowOpacity = 0.5f;
    self.coinsBar.layer.shadowColor = [UIColor blackColor].CGColor;
    
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
    [[DDStoreKitController sharedController] setDelegate:nil];
    [products release];
    [viewCoinsContainer release];
    [tableView release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (DDCoinsBar*)coinsBar
{
    for (DDCoinsBar *v in [self.viewCoinsContainer subviews])
    {
        if ([v isKindOfClass:[DDCoinsBar class]])
            return v;
    }
    return nil;
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
    tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check purchase section
    if (indexPath.section == 2)
    {
        //get pid
        NSString *pid = [[self.products objectAtIndex:indexPath.row] identifier];
        
        //set delegate
        [[DDStoreKitController sharedController] setDelegate:self];
        
        //purchase product
        [[DDStoreKitController sharedController] purchaseProductWithPid:pid];
    }
}

- (CGFloat)tableView:(UITableView *)aTableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if (section == 1)
    {
        return 1;
    }
    else if (section == 2)
    {
        return 40;
    }
    return FLT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 5;
    }
    else if (section == 1)
    {
        return 1;
    }
    else if (section == 2)
        return 40;
    return FLT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 2)
    {
        UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)] autorelease];
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 300, 40)] autorelease];
        label.text = [NSLocalizedString(@"Choose a Package Below", nil) uppercaseString];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        
        [headerView addSubview:label];
        return headerView;
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
        
        //get product
        DDInAppProduct *product = [self.products objectAtIndex:indexPath.row];
        
        //apply value
        tableViewCell.labelAmount.text = [NSString stringWithFormat:@"%d", [product.coins intValue]];
        tableViewCell.labelCost.text = [[DDStoreKitController sharedController] localizedPriceOfProductWithPid:product.identifier];
        tableViewCell.labelPopular.hidden = ![product.popular boolValue];
        tableViewCell.imageViewPopular.hidden = tableViewCell.labelPopular.hidden;
        
        return tableViewCell;
    }
    
    return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
}

#pragma mark store

- (void)productPurchasingIsNotAuthorized
{
    //unset delegate
    [[DDStoreKitController sharedController] setDelegate:nil];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"You are not authorized to make a payment", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)productPurchased:(NSString*)pid
{
    //unset delegate
    [[DDStoreKitController sharedController] setDelegate:nil];
    
    //get money to increase
    NSInteger coins = 0;
    for (DDInAppProduct *product in self.products)
    {
        if ([product.identifier isEqualToString:pid])
            coins = [product.coins intValue];
    }
    
    //update total coins
    NSInteger totalCoins = [[[DDAuthenticationController currentUser] totalCoins] intValue] + coins;
    [[DDAuthenticationController currentUser] setTotalCoins:[NSNumber numberWithInt:totalCoins]];
    
    //inform about change
    [[NSNotificationCenter defaultCenter] postNotificationName:DDObjectsControllerDidUpdateObjectNotification object:[DDAuthenticationController currentUser]];
    
    //update coins bar
    [self.coinsBar setValue:totalCoins];
}

- (void)productPurchasingFailed:(NSError*)error
{
    //unset delegate
    [[DDStoreKitController sharedController] setDelegate:nil];
}

@end
