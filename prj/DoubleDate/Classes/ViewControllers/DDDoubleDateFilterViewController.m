//
//  DDDoubleDateFilterViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 14.11.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDateFilterViewController.h"

@interface DDDoubleDateFilterViewController ()

@end

@implementation DDDoubleDateFilterViewController

@synthesize labelSort;
@synthesize viewSortContainer;

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
    
    //unset parameters
    self.labelSort.backgroundColor = [UIColor clearColor];
    DD_F_HEADER_MAIN(self.labelSort);
    self.viewSortContainer.backgroundColor = [UIColor clearColor];
    
    //add sort segmented control
    NSInteger itemWidth = self.viewSortContainer.frame.size.width/3;
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"MAGIC", nil) width:itemWidth]];
    [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"CLOSEST", nil) width:itemWidth]];
    [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"NEWEST", nil) width:itemWidth]];
    DDSegmentedControl *sortSegmentedControl = [[[DDSegmentedControl alloc] initWithItems:items style:DDSegmentedControlStyleLarge] autorelease];
    sortSegmentedControl.frame = CGRectMake(0, 0, self.viewSortContainer.frame.size.width, self.viewSortContainer.frame.size.height);
    [self.viewSortContainer addSubview:sortSegmentedControl];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [labelSort release], labelSort = nil;
    [viewSortContainer release], viewSortContainer = nil;
}

- (void)dealloc
{
    [labelSort release];
    [viewSortContainer release];
    [super dealloc];
}

@end
