//
//  DDDoubleDateFilterViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 14.11.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDateFilterViewControllerNew.h"
#import "DDTools.h"
#import "DDButton.h"
#import "DDBarButtonItem.h"
#import "DDDoubleDateFilter.h"
#import "DDSegmentedControlTableViewCell.h"

@interface DDDoubleDateFilterViewControllerNew ()

@end

@implementation DDDoubleDateFilterViewControllerNew

@synthesize delegate;

- (id)initWithFilter:(DDDoubleDateFilter*)filter
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        filter_ = [filter retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Filter & Sort", nil);
    
    //set right button
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Done", nil) target:self action:@selector(applyTouched:)];
    
    //set left button
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)dealloc
{
    [filter_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (void)applyTouched:(id)sender
{
    DDDoubleDateFilter *filter = [[[DDDoubleDateFilter alloc] init] autorelease];
    [self.delegate doubleDateFilterViewControllerDidAppliedFilter:filter];
}

- (void)cancelTouched:(id)sender
{
    [self.delegate doubleDateFilterViewControllerDidCancel];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //add sort segmented control
    NSInteger itemWidth = 100;
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"CLOSEST", nil) width:itemWidth]];
    [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"NEWEST", nil) width:itemWidth]];
    [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"OLDEST", nil) width:itemWidth]];
    
    DDSegmentedControlTableViewCell *cell = [[[DDSegmentedControlTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil items:items segmentedContolStyle:DDSegmentedControlStyleLarge] autorelease];
    cell.textLabel.text = @"XX";
    return cell;
}

@end
