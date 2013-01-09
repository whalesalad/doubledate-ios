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
#import "DDTableViewController+Refresh.h"
#import "DDSearchBar.h"

DECLARE_HUD_WITH_PROPERTY(DDTableViewController, hud_)
DECLARE_API_CONTROLLER_WITH_PROPERTY(DDTableViewController, apiController_)
DECLARE_BUFFER_WITH_PROPERTY(DDTableViewController, buffer_)

@interface DDTableViewController (hidden)

@end

@implementation DDTableViewController

@synthesize searchTerm = searchTerm_;
@synthesize backButtonTitle;
@synthesize moveWithKeyboard;

- (void)initSelf
{
    apiController_ = [[DDAPIController alloc] init];
    apiController_.delegate = self;
    
    self.backButtonTitle = NSLocalizedString(@"Back", nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
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

- (id)initWithStyle:(UITableViewStyle)style
{
    if ((self = [super initWithStyle:style]))
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
    self.navigationItem.leftBarButtonItem = [DDBarButtonItem backBarButtonItemWithTitle:self.backButtonTitle target:self action:@selector(backTouched:)];
    
    //add search bar
    [self setupSearchBar];
    
    //add refresh control
    [self setIsRefreshControlEnabled:YES];
    
    //move header
    self.tableView.contentOffset = CGPointMake(0, self.searchBar.frame.size.height);
}

- (void)backTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupSearchBar
{
    //set header as search bar
    self.tableView.tableHeaderView = [[[DDSearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    self.searchBar.delegate = self;
}

- (UISearchBar*)searchBar
{
    if ([self.tableView.tableHeaderView isKindOfClass:[UISearchBar class]])
        return (UISearchBar*)self.tableView.tableHeaderView;
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    apiController_.delegate = nil;
    [apiController_ release];
    [searchTerm_ release];
    [backButtonTitle release];
    [self hideHud:YES];
    [super dealloc];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar
{
    [searchTerm_ release];
    searchTerm_ = [aSearchBar.text retain];
    [self.tableView reloadData];
    [aSearchBar setShowsCancelButton:YES animated:YES];
    [self setIsRefreshControlEnabled:NO];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar
{
    [aSearchBar setShowsCancelButton:NO animated:YES];
    [self setIsRefreshControlEnabled:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    [self.tableView reloadData];
    [aSearchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar
{
    [searchTerm_ release];
    searchTerm_ = nil;
    [self.tableView reloadData];
    [aSearchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [searchTerm_ release];
    searchTerm_ = [searchText retain];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark UIKeyboard

- (void)keyboardWillShowNotification:(NSNotification*)notification
{
    //check if we need to move together with keyboard
    if (self.moveWithKeyboard)
    {
        //save moved flag
        movedWithKeyboard_ = YES;
        
        //apply change
        CGSize keyBoardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        [UIView beginAnimations:@"KeyboardWillShow" context:nil];
        [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y - (keyBoardSize.height - self.tabBarController.tabBar.frame.size.height));
        [UIView commitAnimations];
    }
    else
        movedWithKeyboard_ = NO;
}

- (void)keyboardWillHideNotification:(NSNotification*)notification
{
    //cehck if we need to hide
    if (movedWithKeyboard_)
    {
        //apply change
        CGSize keyBoardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        [UIView beginAnimations:@"KeyboardWillHide" context:nil];
        [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y + (keyBoardSize.height - self.tabBarController.tabBar.frame.size.height));
        [UIView commitAnimations];
    }
}

@end
