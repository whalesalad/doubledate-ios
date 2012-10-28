//
//  DDDoubleDatesViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDatesViewController.h"
#import "DDCreateDoubleDateViewController.h"
#import "DDDoubleDate.h"

@interface DDDoubleDatesViewController () <UITableViewDataSource, UITableViewDelegate>

- (void)refresh:(BOOL)animated;

@end

@implementation DDDoubleDatesViewController

@synthesize tableView;
@synthesize user;
@synthesize doubleDateToAdd;

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
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Double Dates", nil);
    
    //add left button
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(plusTouched:)] autorelease];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //add doubledate if needed
    if (self.doubleDateToAdd)
    {
        //add doubledate
        [doubleDates_ addObject:self.doubleDateToAdd];
        
        //reload the table
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check if we need to make a request
    if (!doubleDates_)
        [self refresh:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [tableView release], tableView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [doubleDates_ release];
    [tableView release];
    [user release];
    [doubleDateToAdd release];
    [super dealloc];
}

#pragma mark -
#pragma comment other

- (void)plusTouched:(id)sender
{
    DDCreateDoubleDateViewController *viewController = [[[DDCreateDoubleDateViewController alloc] init] autorelease];
    viewController.user = self.user;
    viewController.doubleDatesViewController = self;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)refresh:(BOOL)animated
{
    //unset old values
    [doubleDates_ release];
    doubleDates_ = nil;
    
    //show hud
    [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:animated];
    
    //request doubledates
    [self.apiController getDoubleDates];
}

#pragma mark -
#pragma comment UITableViewDelegate

#pragma mark -
#pragma comment UITableViewDataSource

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [doubleDates_ count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //create cell
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:[[UITableViewCell class] description]];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[UITableViewCell class] description]];
    
    //apply data
    DDDoubleDate *doubleDate = [doubleDates_ objectAtIndex:indexPath.row];
    cell.textLabel.text = [doubleDate title];
    
    return cell;
}

#pragma mark -
#pragma comment API

- (void)getDoubleDatesSucceed:(NSArray*)doubleDates
{
    //hide hud
    [self hideHud:YES];
    
    //save doubledates
    [doubleDates_ release];
    doubleDates_ = [[NSMutableArray arrayWithArray:doubleDates] retain];
    
    //reload data
    [self.tableView reloadData];
}

- (void)getDoubleDatesDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //save friends
    [doubleDates_ release];
    doubleDates_ = [[NSMutableArray alloc] init];
    
    //inform about reloaded data
    [self.tableView reloadData];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
