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
#import "DDDoubleDateViewTableViewCell.h"

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
    
    //add right button
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(editTouched:)] autorelease];
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

- (void)editTouched:(id)sender
{
    //update edigin style
    self.tableView.editing = !self.tableView.editing;
    
    //set right button
    if (self.tableView.editing)
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(editTouched:)] autorelease];
    else
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(editTouched:)] autorelease];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *ret = [[[UIView alloc] init] autorelease];
    ret.backgroundColor = [UIColor clearColor];
    return ret;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *ret = [[[UIView alloc] init] autorelease];
    ret.backgroundColor = [UIColor clearColor];
    return ret;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

#pragma mark -
#pragma comment UITableViewDataSource

- (BOOL)tableView:(UITableView *)aTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //get doubledate
        DDDoubleDate *doubleDate = [[doubleDates_ objectAtIndex:indexPath.row] retain];

        //remove sliently
        [doubleDates_ removeObject:doubleDate];
        
        //reload the table
        [self.tableView reloadData];
        
        //request delete doubledate
        [self.apiController requestDeleteDoubleDate:doubleDate];
        
        //release object
        [doubleDate release];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [doubleDates_ count];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //save class
    Class cellClass = [DDDoubleDateViewTableViewCell class];
    
    //create cell
    DDDoubleDateViewTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:[cellClass description]];
    if (!cell)
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[cellClass description]];
    
    //apply data
    cell.doubleDate = [doubleDates_ objectAtIndex:indexPath.section];
    
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

- (void)requestDeleteDoubleDateSucceed
{
}

- (void)requestDeleteDoubleDateDidFailedWithError:(NSError*)error
{
    //reload data
    [self refresh:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
