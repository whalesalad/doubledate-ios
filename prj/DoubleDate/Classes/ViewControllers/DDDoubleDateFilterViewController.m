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
    
    //add sort segmented control
    DDSegmentedControl *sortSegmentedControl = [[[DDSegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"MAGIC", nil), NSLocalizedString(@"CLOSEST", nil), NSLocalizedString(@"NEWEST", nil), nil] style:DDSegmentedControlStyleBlackLarge] autorelease];
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
