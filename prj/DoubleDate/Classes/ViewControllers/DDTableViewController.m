//
//  DDTableViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewController.h"
#import "MBProgressHUD.h"
#import "DDAppDelegate.h"
#import "DDAPIController.h"
#import "DDBarButtonItem.h"
#import <QuartzCore/QuartzCore.h>
#import "DDTools.h"
#import "UIViewController+Extensions.h"

DECLARE_HUD_WITH_PROPERTY(DDTableViewController, hud_)
DECLARE_API_CONTROLLER_WITH_PROPERTY(DDTableViewController, apiController_)
DECLARE_BUFFER_WITH_PROPERTY(DDTableViewController, buffer_)

@interface DDTableViewController (hidden) <DDAPIControllerDelegate>

@end

@implementation DDTableViewController

- (void)initSelf
{
    apiController_ = [[DDAPIController alloc] init];
    apiController_.delegate = self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initSelf];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        [self initSelf];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set background color
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dd-pinstripe-background"]];
    
    //set table view properties
    [self.tableView setBackgroundView:[[[UIImageView alloc] initWithImage:[DDTools clearImage]] autorelease]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    //customize navigation bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav-background.png"] forBarMetrics:UIBarMetricsDefault];
    
    //customize left button
    self.navigationItem.leftBarButtonItem = [DDBarButtonItem backBarButtonItemWithTitle:NSLocalizedString(@"BACK", nil) target:self action:@selector(backTouched:)];
}

- (void)backTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    apiController_.delegate = nil;
    [apiController_ release];
    [self hideHud:YES];
    [super dealloc];
}

@end
