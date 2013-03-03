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

@interface DDPurchaseViewController ()

@property(nonatomic, readonly) DDCoinsBar *coinsBar;

@end

@implementation DDPurchaseViewController

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

#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
