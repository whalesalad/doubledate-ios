//
//  DDTableViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
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
#import "DDAppDelegate+NavigationMenu.h"

DECLARE_HUD_WITH_PROPERTY(DDTableViewController, hud_)
DECLARE_API_CONTROLLER_WITH_PROPERTY(DDTableViewController, apiController_)
DECLARE_BUFFER_WITH_PROPERTY(DDTableViewController, buffer_)

@interface DDTableViewController (hidden)

@end

@implementation DDTableViewController

@synthesize showsCancelButton;
@synthesize searchTerm = searchTerm_;
@synthesize backButtonTitle;
@synthesize moveWithKeyboard;
@synthesize viewNoData = viewNoData_;
@synthesize shouldShowNavigationMenu;
@synthesize cellsIdentifiers;

- (void)initSelf
{
    apiController_ = [[DDAPIController alloc] init];
    apiController_.delegate = self;
    
    self.backButtonTitle = NSLocalizedString(@"Back", nil);
    
    self.showsCancelButton = YES;
    
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
    
    //register cells
    for (NSString *key in self.cellsIdentifiers)
        [self.tableView registerNib:[UINib nibWithNibName:[self.cellsIdentifiers objectForKey:key] bundle:nil] forCellReuseIdentifier:key];
    
    //set background color
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dd-pinstripe-background"]];
    
    //set table view properties
    [self.tableView setBackgroundView:[[[UIImageView alloc] initWithImage:[DDTools clearImage]] autorelease]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    //add no messages
    viewNoData_ = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)] autorelease];
    viewNoData_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    viewNoData_.hidden = YES;
    [self.tableView addSubview:viewNoData_];
    
    //customize navigation bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav-background.png"] forBarMetrics:UIBarMetricsDefault];
    
    //customize left button
    if ([self shouldShowNavigationMenu])
    {
        DDBarButtonItem *menuButton = [DDBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"nav-menu-btn.png"] target:self action:@selector(menuTouched:)];
        
        menuButton.showsApplicationBadgeNumber = YES;
        
        CGRect menuButtonFrame = menuButton.button.frame;
        menuButtonFrame.size.width += 10;
        menuButton.button.frame = menuButtonFrame;
        
        self.navigationItem.leftBarButtonItem = menuButton;
    }
    else
    {
        self.navigationItem.leftBarButtonItem = [DDBarButtonItem backBarButtonItemWithTitle:self.backButtonTitle target:self action:@selector(backTouched:)];
    }
    
    
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

- (void)menuTouched:(id)sender
{
    DDAppDelegate *appDelegate = (DDAppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isNavigationMenuExist])
        [appDelegate dismissNavigationMenu];
    else
        [appDelegate presentNavigationMenu];
}

- (void)setupSearchBar
{
    //set header as search bar
    self.tableView.tableHeaderView = [[[DDSearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    self.searchBar.delegate = self;
}

- (DDSearchBar*)searchBar
{
    if ([self.tableView.tableHeaderView isKindOfClass:[DDSearchBar class]])
        return (DDSearchBar*)self.tableView.tableHeaderView;
    return nil;
}

- (void)updateNoDataView
{
    NSInteger totalNumberOfRows = 0;
    for (int i = 0; i < [self numberOfSectionsInTableView:self.tableView]; i++)
        totalNumberOfRows += [self tableView:self.tableView numberOfRowsInSection:i];
    self.viewNoData.hidden = !(totalNumberOfRows == 0 && [self.searchTerm length] == 0 && ![self isRefreshing]);
//    self.tableView.scrollEnabled = totalNumberOfRows > 0;
    if (previousSearchBar_ && totalNumberOfRows > 0)
    {
        self.tableView.tableHeaderView = previousSearchBar_;
        [previousSearchBar_ release];
        previousSearchBar_ = nil;
    }
    else if (totalNumberOfRows == 0 && [self.searchTerm length] == 0)
    {
        [previousSearchBar_ release];
        previousSearchBar_ = [self.searchBar retain];
        self.tableView.tableHeaderView = nil;
    }
}

- (void)updateNoDataPercentage
{
    if (self.refreshControl)
    {
        CGFloat alpha = -self.tableView.contentOffset.y / self.refreshControl.frame.size.height;
        self.viewNoData.alpha = 1.0f - MAX(MIN(alpha, 1), 0);
    }
    else
        self.viewNoData.alpha = 1;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [searchTerm_ release];
    [previousSearchBar_ release];
    [backButtonTitle release];
    [cellsIdentifiers release];
    [self hideHud:YES];
    self.apiController.delegate = nil;
    self.apiController = nil;
    self.hud = nil;
    self.buffer = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar
{
    [searchTerm_ release];
    searchTerm_ = [aSearchBar.text retain];
    [self.tableView reloadData];
    if (self.showsCancelButton)
        [aSearchBar setShowsCancelButton:YES animated:YES];
    refreshControlEnabled_ = [self isRefreshControlEnabled];
    [self setIsRefreshControlEnabled:NO];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar
{
    [aSearchBar setShowsCancelButton:NO animated:YES];
    [self setIsRefreshControlEnabled:refreshControlEnabled_];
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
    [self onChangedSearchTerm];
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

#pragma mark -
#pragma mark UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.tableView == scrollView)
    {
        [self updateNoDataPercentage];
        self.viewNoData.frame = CGRectMake(self.viewNoData.frame.origin.x, scrollView.contentOffset.y, self.viewNoData.frame.size.width, self.viewNoData.frame.size.height);
    }
}

@end
