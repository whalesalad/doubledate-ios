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
- (NSArray*)doubleDates;
- (void)segmentedControlTouched:(id)sender;
- (void)onDataRefreshed;
- (void)removeDoubleDate:(DDDoubleDate*)doubleDate;

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
        mode_ = DDDoubleDatesViewControllerModeAll;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"List", nil), NSLocalizedString(@"Mine", nil), nil]] autorelease];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    if (mode_ == DDDoubleDatesViewControllerModeAll)
        segmentedControl.selectedSegmentIndex = 0;
    else if (mode_ == DDDoubleDatesViewControllerModeMine)
        segmentedControl.selectedSegmentIndex = 1;
    [segmentedControl addTarget:self action:@selector(segmentedControlTouched:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentedControl;
    
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
        [allDoubleDates_ addObject:self.doubleDateToAdd];
        [mineDoubleDates_ addObject:self.doubleDateToAdd];
        
        //reload the table
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check if we need to make a request
    if (!allDoubleDates_ || !mineDoubleDates_)
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
    [allDoubleDates_ release];
    [mineDoubleDates_ release];
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
    [allDoubleDates_ release];
    allDoubleDates_ = nil;
    [mineDoubleDates_ release];
    mineDoubleDates_ = nil;
    
    //show hud
    [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:animated];
    
    //request doubledates
    [self.apiController getDoubleDates];
    
    //request doubledates
    [self.apiController getMyDoubleDates];
}

- (NSArray*)doubleDates
{
    if (mode_ == DDDoubleDatesViewControllerModeAll)
        return allDoubleDates_;
    else if (mode_ == DDDoubleDatesViewControllerModeMine)
        return mineDoubleDates_;
    return nil;
}

- (void)segmentedControlTouched:(UISegmentedControl*)sender
{
    //switch mode
    switch (sender.selectedSegmentIndex)
    {
        case 0:
            mode_ = DDDoubleDatesViewControllerModeAll;
            break;
        case 1:
            mode_ = DDDoubleDatesViewControllerModeMine;
            break;
        default:
            break;
    }
    
    //reload the table
    [self.tableView reloadData];
}

- (void)onDataRefreshed
{
    //check for both data
    if (allDoubleDates_ && mineDoubleDates_)
    {
        //hide hud
        [self hideHud:YES];
    
        //reload data
        [self.tableView reloadData];
    }
}

- (void)removeDoubleDate:(DDDoubleDate*)doubleDate
{
    //init array
    NSMutableArray *doubleDatesToRemove = [NSMutableArray array];

    //add from all doubledates
    for (DDDoubleDate *d in allDoubleDates_)
    {
        if ([[d identifier] intValue] == [[doubleDate identifier] intValue])
            [doubleDatesToRemove addObject:d];
    }
    
    //add from mine doubledates
    for (DDDoubleDate *d in mineDoubleDates_)
    {
        if ([[d identifier] intValue] == [[doubleDate identifier] intValue])
            [doubleDatesToRemove addObject:d];
    }
    
    //remove
    while ([doubleDatesToRemove count])
    {
        DDDoubleDate *d = [doubleDatesToRemove lastObject];
        [allDoubleDates_ removeObject:d];
        [mineDoubleDates_ removeObject:d];
        [doubleDatesToRemove removeObject:d];
    }
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
        DDDoubleDate *doubleDate = [[[self doubleDates] objectAtIndex:indexPath.row] retain];

        //remove sliently
        [self removeDoubleDate:doubleDate];
        
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
    return [[self doubleDates] count];
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
    cell.doubleDate = [[self doubleDates] objectAtIndex:indexPath.section];
    
    return cell;
}

#pragma mark -
#pragma comment API

- (void)getDoubleDatesSucceed:(NSArray*)doubleDates
{
    //save doubledates
    [allDoubleDates_ release];
    allDoubleDates_ = [[NSMutableArray arrayWithArray:doubleDates] retain];
    
    //inform about completion
    [self onDataRefreshed];
}

- (void)getDoubleDatesDidFailedWithError:(NSError*)error
{
    //save friends
    [allDoubleDates_ release];
    allDoubleDates_ = [[NSMutableArray alloc] init];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
    
    //inform about completion
    [self onDataRefreshed];
}

- (void)getMyDoubleDatesSucceed:(NSArray*)doubleDates
{
    //save doubledates
    [mineDoubleDates_ release];
    mineDoubleDates_ = [[NSMutableArray arrayWithArray:doubleDates] retain];
    
    //inform about completion
    [self onDataRefreshed];
}

- (void)getMyDoubleDatesDidFailedWithError:(NSError*)error
{
    //save friends
    [mineDoubleDates_ release];
    mineDoubleDates_ = [[NSMutableArray alloc] init];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
    
    //inform about completion
    [self onDataRefreshed];
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
