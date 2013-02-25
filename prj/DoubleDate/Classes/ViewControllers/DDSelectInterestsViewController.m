//
//  DDSelectInterestsViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 08.10.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDSelectInterestsViewController.h"
#import "DDBarButtonItem.h"
#import "DDTableViewController+Refresh.h"
#import "DDTableViewCell.h"
#import "DDInterest.h"
#import "DDSearchBar.h"
#import "DDTools.h"

@interface DDSelectInterestsViewController ()

@property(nonatomic, assign) BOOL searchMode;

@end

@implementation DDSelectInterestsViewController

@synthesize searchMode;
@synthesize selectedInterests;
@synthesize maxInterestsCount;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Add an Interes", nil);
    
    //add right button
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Done", nil) target:self action:@selector(doneTouched:)];
    
    //disable reloading
    [self setIsRefreshControlEnabled:NO];
    
    //load data
    [self onRefresh];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [allInterests_ release];
    [selectedInterests release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (void)onDataRefreshed
{
    //hide loading
    [self finishRefresh];
    
    //reload the table
    [self.tableView reloadData];
    
    //update no messages
    [self updateNoDataView];
}

- (void)doneTouched:(id)sender
{
    
}

- (NSArray*)interestsToShow
{
    if (self.searchMode)
    {
        NSMutableArray *ret = [NSMutableArray array];
        
        //add filtered objects from interests
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
        }
        
        //add search word
        if ([self.searchTerm length])
            [ret addObject:self.searchTerm];
        
        return ret;
    }
    else
        return self.selectedInterests;
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
        
        //save if interest already exist
        BOOL interestAlreadyExist = NO;
        for (DDInterest *i in self.selectedInterests)
        {
            if ([[i name] isEqualToString:selectedInterestName])
                interestAlreadyExist = YES;
        }
        
        //check if interest already exist
        if (!interestAlreadyExist)
        {
            //create object
            DDInterest *interest = [[[DDInterest alloc] init] autorelease];
            interest.name = selectedInterestName;
            
            //set interests
            self.selectedInterests = [self.selectedInterests arrayByAddingObject:interest];
        }
    }
    
    //unset search mode
    self.searchMode = NO;
    
    //reload data
    [self.tableView reloadData];
    
    //resign first responder
    [[self.searchBar textField] resignFirstResponder];
    
    //unset search text
    [[self.searchBar textField] setText:nil];
    
    //deselect then
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
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
        return [self viewForHeaderWithMainText:NSLocalizedString(@"INTERESTS TO SELECT", nil) detailedText:nil];
    }
    else
    {
        return [self viewForHeaderWithMainText:NSLocalizedString(@"YOUR INTERESTS", nil) detailedText:nil];
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
    tableViewCell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"interest-tablecell-bg.png"]] autorelease];
    
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
    [super searchBarTextDidBeginEditing:aSearchBar];
    self.searchMode = YES;
    [self.tableView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar
{
    [super searchBarTextDidEndEditing:aSearchBar];
    self.searchMode = NO;
    [self.tableView reloadData];
}

- (void)onChangedSearchTerm
{
    [super onChangedSearchTerm];
    [self onRefresh];
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
    
    //update search mode
    if (self.maxInterestsCount && [selectedInterests count] < self.maxInterestsCount)
        [self setupSearchBar];
    else
        [self.tableView setTableHeaderView:nil];
}

- (void)setMaxInterestsCount:(NSInteger)v
{
    //update vaue
    if (v != maxInterestsCount)
    {
        maxInterestsCount = v;
    }
    
    //update search mode
    if (self.maxInterestsCount && [selectedInterests count] < self.maxInterestsCount)
        [self setupSearchBar];
    else
        [self.tableView setTableHeaderView:nil];
}

@end
