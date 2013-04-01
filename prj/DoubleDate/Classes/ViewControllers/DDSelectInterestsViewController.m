//
//  DDSelectInterestsViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 08.10.12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDSelectInterestsViewController.h"
#import "DDBarButtonItem.h"
#import "DDTableViewController+Refresh.h"
#import "DDTableViewCell.h"
#import "DDInterest.h"
#import "DDSearchBar.h"
#import "DDTools.h"

@interface DDSelectInterestsViewController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, assign) BOOL searchMode;
@property(nonatomic, retain) UITableView *tableView;
@property(nonatomic, retain) DDSearchBar *searchBar;

- (void)onRefresh;

@end

@implementation DDSelectInterestsViewController

@synthesize searchMode;
@synthesize tableView;
@synthesize searchBar;
@synthesize selectedInterests;
@synthesize maxInterestsCount;
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Add an Interest", nil);
    
    //add right button
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Done", nil) target:self action:@selector(doneTouched:)];
    
    //load data
    [self onRefresh];
    
    //add search bar
    self.searchBar = [[[DDSearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    self.searchBar.delegate = self;
    [self.searchBar setShowsCancelButton:YES animated:NO];
    [self.view addSubview:self.searchBar];
    
    //set search mode
    self.searchMode = YES;
    
    //set content insets as we have search bar
    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, self.view.frame.size.height-44-216) style:UITableViewStylePlain] autorelease];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    //set table view properties
    [self.tableView setBackgroundView:[[[UIImageView alloc] initWithImage:[DDTools clearImage]] autorelease]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //hide navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    //unsetup search bar
    self.tableView.tableHeaderView = nil;
    
    //reload data
    [self.tableView reloadData];
    
    //enable cancel button
    [self.searchBar.textField becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [allInterests_ release];
    [selectedInterests release];
    [interestsToShow_ release];
    [tableView release];
    [searchBar release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (void)onDataRefreshed
{
    //update filtered interests
    [interestsToShow_ release];
    interestsToShow_ = [[self interestsToShowInternal] retain];
    
    //reload the table
    [self.tableView reloadData];
}

- (void)doneTouched:(id)sender
{
    
}

- (NSString*)searchTerm
{
    return self.searchBar.text;
}

- (NSArray*)interestsToShowInternal
{
    if (self.searchMode)
    {
        NSMutableArray *ret = [NSMutableArray array];
        
        //add filtered objects from interests
        BOOL existTheSameName = NO;
        for (DDInterest *i in allInterests_)
        {
            //check search condition
            BOOL existInSearch = [self.searchTerm length] == 0;
            if (self.searchTerm)
            {
                if (i.name && [i.name rangeOfString:self.searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)
                    existInSearch = YES;
            }
            
            //check if we can add the double date
            if (existInSearch)
                [ret addObject:i];
            
            //check if exactly the same name
            if ([self.searchTerm length] && [[self.searchTerm lowercaseString] isEqualToString:[i.name lowercaseString]])
                existTheSameName = YES;
        }
        
        //add search word
        if ([self.searchTerm length] && !existTheSameName)
            [ret addObject:self.searchTerm];
        
        return ret;
    }
    else
        return self.selectedInterests;
}

- (NSArray*)interestsToShow
{
    return interestsToShow_;
}

- (NSString*)interestNameForIndexPath:(NSIndexPath*)indexPath
{
    NSObject *interest = [[self interestsToShow] objectAtIndex:indexPath.row];
    if ([interest isKindOfClass:[NSString class]])
        return (NSString*)interest;
    else if ([interest isKindOfClass:[DDInterest class]])
        return [(DDInterest*)interest name];
    return nil;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DDTableViewCell height];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check if search mode
    if (self.searchMode)
    {
        //save selected interest
        NSString *selectedInterestName = [self interestNameForIndexPath:indexPath];
        
        //create object
        DDInterest *interest = [[[DDInterest alloc] init] autorelease];
        interest.name = selectedInterestName;
        
        //inform delegate
        [self.delegate selectInterestsViewController:self didSelectInterest:interest];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    return [[self tableView:aTableView viewForHeaderInSection:section] frame].size.height;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    if ([self tableView:aTableView numberOfRowsInSection:section] == 0)
        return nil;
    
    if (self.searchMode)
    {
        return [self viewForHeaderWithMainText:NSLocalizedString(@"Popular Interests", nil) detailedText:nil];
    }
    else
    {
        return [self viewForHeaderWithMainText:NSLocalizedString(@"Your Interests", nil) detailedText:nil];
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [[self interestsToShow] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set identifier
    NSString *cellIdentifier = NSStringFromClass([DDTableViewCell class]);
    assert(cellIdentifier);
    
    //create cell if needed
    DDTableViewCell *tableViewCell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!tableViewCell)
    {
        tableViewCell = [[[DDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    //apply needed style
    tableViewCell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"interest-search-tablecell.png"]] autorelease];
    
    //disable selection
    tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //set cell text
    tableViewCell.textLabel.text = [self interestNameForIndexPath:indexPath];
        
    //update layouts
    [tableViewCell setNeedsLayout];
    
    return tableViewCell;
}

#pragma mark -
#pragma mark API

- (void)requestAvailableInterestsSucceed:(NSArray*)interests
{
    //hide hud
    [self hideHud:YES];
    
    //save data
    [allInterests_ release];
    allInterests_ = [interests retain];
    
    //refresh data
    [self onDataRefreshed];
}

- (void)requestAvailableInterestsDidFailedWithError:(NSError*)error
{
    //check for cancelling
    if ([error code] == DDErrorTypeCancelled && [[error domain] isEqualToString:DDErrorDomain])
    {
        
    }
    else
    {
        //hide hud
        [self hideHud:YES];
    
        //show error
        [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
    }
}

#pragma mark -
#pragma mark -

- (void)onRefresh
{
    //request interests
    [self.apiController cancelRequest:request_];
    request_ = [self.apiController requestAvailableInterestsWithQuery:self.searchTerm];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar
{
    self.searchMode = YES;
    [self.tableView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar
{
    self.searchMode = NO;
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self onRefresh];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar
{
    [self.delegate selectInterestsViewControllerDidCancel:self];
}

#pragma mark -
#pragma mark Setters

- (void)setSelectedInterests:(NSArray *)v
{
    //update vaue
    if (v != selectedInterests)
    {
        [selectedInterests release];
        selectedInterests = [v retain];
    }
}

- (void)setMaxInterestsCount:(NSInteger)v
{
    //update vaue
    if (v != maxInterestsCount)
    {
        maxInterestsCount = v;
    }
}

@end
