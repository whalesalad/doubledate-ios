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

@synthesize tableView;
@synthesize coinsBarContainer;

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
    
    //register cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DDInAppProductTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DDInAppProductTableViewCell class])];
    
    //add coin bar
    [self.coinsBarContainer addSubview:[[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DDCoinsBar class]) owner:self options:nil] objectAtIndex:0]];
    
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
    [tableView release];
    [coinsBarContainer release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (DDCoinsBar*)coinsBar
{
    for (DDCoinsBar *v in [self.coinsBarContainer subviews])
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

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DDInAppProductTableViewCell height];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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

@end
