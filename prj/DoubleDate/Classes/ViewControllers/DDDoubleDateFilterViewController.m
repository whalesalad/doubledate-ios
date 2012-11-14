//
//  DDDoubleDateFilterViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 14.11.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDateFilterViewController.h"
#import "DDTools.h"
#import "DDButton.h"

@interface DDDoubleDateFilterViewController ()

- (void)updateArrowForButton:(UIButton*)button;

@end

@implementation DDDoubleDateFilterViewController

@synthesize labelSort;
@synthesize viewSortContainer;
@synthesize labelWhen;
@synthesize viewWhenContainer;
@synthesize labelDistance;
@synthesize viewDistanceContainer;
@synthesize labelMinAge;
@synthesize viewMinAgeContainer;
@synthesize labelMaxAge;
@synthesize viewMaxAgeContainer;

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
    self.labelMinAge.backgroundColor = [UIColor clearColor];
    DD_F_HEADER_MAIN(self.labelMinAge);
    self.viewMinAgeContainer.backgroundColor = [UIColor clearColor];
    self.labelMaxAge.backgroundColor = [UIColor clearColor];
    DD_F_HEADER_MAIN(self.labelMaxAge);
    self.viewMaxAgeContainer.backgroundColor = [UIColor clearColor];
    
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
        //add button
        UIButton *button = [DDToggleButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, self.viewDistanceContainer.frame.size.width, self.viewDistanceContainer.frame.size.height);
        [button setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"large-button.png"]] forState:UIControlStateNormal];
        [button setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"large-button-highlight.png"]] forState:UIControlStateHighlighted];
        DD_F_BUTTON_LARGE(button);
        [button setTitle:NSLocalizedString(@"WITHIN 50 MILES OF ME", nil) forState:UIControlStateNormal];
        [self.viewDistanceContainer addSubview:button];
        
        //update arrow
        [self updateArrowForButton:button];
    }
    
    //add button
    {
        //add button
        UIButton *button = [DDToggleButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, self.viewMinAgeContainer.frame.size.width, self.viewMinAgeContainer.frame.size.height);
        [button setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"large-button.png"]] forState:UIControlStateNormal];
        [button setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"large-button-highlight.png"]] forState:UIControlStateHighlighted];
        DD_F_BUTTON_LARGE(button);
        [button setTitle:NSLocalizedString(@"20 YEARS", nil) forState:UIControlStateNormal];
        [self.viewMinAgeContainer addSubview:button];
        
        //update arrow
        [self updateArrowForButton:button];
    }
    
    //add button
    {
        //add button
        UIButton *button = [DDToggleButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, self.viewMaxAgeContainer.frame.size.width, self.viewMaxAgeContainer.frame.size.height);
        [button setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"large-button.png"]] forState:UIControlStateNormal];
        [button setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"large-button-highlight.png"]] forState:UIControlStateHighlighted];
        DD_F_BUTTON_LARGE(button);
        [button setTitle:NSLocalizedString(@"20 YEARS", nil) forState:UIControlStateNormal];
        [self.viewMaxAgeContainer addSubview:button];
        
        //update arrow
        [self updateArrowForButton:button];
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
    [labelMinAge release], labelMinAge = nil;
    [viewMinAgeContainer release], viewMinAgeContainer = nil;
    [labelMaxAge release], labelMaxAge = nil;
    [viewMaxAgeContainer release], viewMaxAgeContainer = nil;
}

- (void)dealloc
{
    [labelSort release];
    [viewSortContainer release];
    [labelWhen release];
    [viewWhenContainer release];
    [labelDistance release];
    [viewDistanceContainer release];
    [labelMinAge release];
    [viewMinAgeContainer release];
    [labelMaxAge release];
    [viewMaxAgeContainer release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (void)updateArrowForButton:(UIButton *)button
{
    UIImageView *imageView = nil;
    for (UIImageView *iv in [button.superview subviews])
    {
        if ([iv isKindOfClass:[UIImageView class]])
            imageView = iv;
    }
    if (!imageView)
    {
        imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"large-button-down-arrow.png"]] autorelease];
        [button.superview addSubview:imageView];
    }
    imageView.center = CGPointMake(button.frame.size.width/2 + [[button titleForState:UIControlStateNormal] sizeWithFont:[button titleLabel].font].width/2 + 12, button.frame.size.height/2-2);
}

@end
