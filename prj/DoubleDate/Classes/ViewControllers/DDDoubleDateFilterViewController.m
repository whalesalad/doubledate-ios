//
//  DDDoubleDateFilterViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 14.11.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDateFilterViewController.h"
#import "DDTools.h"

@interface DDDoubleDateFilterViewController ()

@end

@implementation DDDoubleDateFilterViewController

@synthesize labelSort;
@synthesize viewSortContainer;
@synthesize labelWhen;
@synthesize viewWhenContainer;
@synthesize labelDistance;
@synthesize viewDistanceContainer;

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
    self.labelWhen.backgroundColor = [UIColor clearColor];
    DD_F_HEADER_MAIN(self.labelWhen);
    self.viewWhenContainer.backgroundColor = [UIColor clearColor];
    self.labelDistance.backgroundColor = [UIColor clearColor];
    DD_F_HEADER_MAIN(self.labelDistance);
    self.viewDistanceContainer.backgroundColor = [UIColor clearColor];
    
    //add sort segmented control
    {
        NSInteger itemWidth = self.viewSortContainer.frame.size.width/3;
        NSMutableArray *items = [NSMutableArray array];
        [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"MAGIC", nil) width:itemWidth]];
        [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"CLOSEST", nil) width:itemWidth]];
        [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"NEWEST", nil) width:itemWidth]];
        DDSegmentedControl *sortSegmentedControl = [[[DDSegmentedControl alloc] initWithItems:items style:DDSegmentedControlStyleLarge] autorelease];
        sortSegmentedControl.frame = CGRectMake(0, 0, self.viewSortContainer.frame.size.width, self.viewSortContainer.frame.size.height);
        [self.viewSortContainer addSubview:sortSegmentedControl];
    }
    
    //add when segmented control
    {
        NSInteger itemWidth = self.viewWhenContainer.frame.size.width/3;
        NSMutableArray *items = [NSMutableArray array];
        [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"ANYTIME", nil) width:itemWidth]];
        [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"WEEKDAY", nil) width:itemWidth]];
        [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"WEEKEND", nil) width:itemWidth]];
        DDSegmentedControl *sortSegmentedControl = [[[DDSegmentedControl alloc] initWithItems:items style:DDSegmentedControlStyleLarge] autorelease];
        sortSegmentedControl.frame = CGRectMake(0, 0, self.viewWhenContainer.frame.size.width, self.viewWhenContainer.frame.size.height);
        [self.viewWhenContainer addSubview:sortSegmentedControl];
    }
    
    //add button
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, self.viewDistanceContainer.frame.size.width, self.viewDistanceContainer.frame.size.height);
        [button setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"large-button.png"]] forState:UIControlStateNormal];
        [button setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"large-button-highlight.png"]] forState:UIControlStateHighlighted];
        DD_F_BUTTON(button);
        [button setTitle:NSLocalizedString(@"WITHIN 50 MILES OF ME", nil) forState:UIControlStateNormal];
        [self.viewDistanceContainer addSubview:button];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [labelSort release], labelSort = nil;
    [viewSortContainer release], viewSortContainer = nil;
    [labelWhen release], labelWhen = nil;
    [viewWhenContainer release], viewWhenContainer = nil;
    [labelDistance release], labelDistance = nil;
    [viewDistanceContainer release], viewDistanceContainer = nil;
}

- (void)dealloc
{
    [labelSort release];
    [viewSortContainer release];
    [labelWhen release];
    [viewWhenContainer release];
    [labelDistance release];
    [viewDistanceContainer release];
    [super dealloc];
}

@end
