//
//  DDSegmentedControl.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDSegmentedControl.h"
#import "DDTools.h"
#import "DDBarButtonItem.h"

@interface DDSegmentedControlItem : NSObject

@property(nonatomic, retain) UIImage *normalImage;
@property(nonatomic, retain) UIImage *highlightedImage;
@property(nonatomic, retain) UIImage *disabledImage;

@end

@implementation DDSegmentedControlItem

@synthesize normalImage;
@synthesize highlightedImage;
@synthesize disabledImage;

- (void)dealloc
{
    [normalImage release];
    [highlightedImage release];
    [disabledImage release];
    [super dealloc];
}

@end

@implementation DDSegmentedControl

- (void)updateItems
{
    //check each item
    for (int i = 0; i < [items_ count]; i++)
    {
        //get item
        DDSegmentedControlItem *item = [items_ objectAtIndex:i];
        
        //swtich image
        UIImage *image = item.normalImage;
        if (![self isEnabledForSegmentAtIndex:i])
            image = item.disabledImage;
        else if ([self selectedSegmentIndex] == i)
            image = item.highlightedImage;
        
        //apply image
        [self setImage:image forSegmentAtIndex:i];
        
        //apply width
        [self setWidth:image.size.width forSegmentAtIndex:i];
    }
}

- (id)initWithItems:(NSArray *)items
{
    //save items for internal representation
    NSMutableArray *itemsInternal = [NSMutableArray array];
    for (NSObject *item in items)
    {
        //support strings only
        assert([item isKindOfClass:[NSString class]]);

        //add bar button items
        DDBarButtonItem *barButtonItem = nil;
        if (item == [items objectAtIndex:0])
            barButtonItem = [DDBarButtonItem leftBarButtonItemWithTitle:(NSString*)item target:nil action:nil];
        else if (item == [items lastObject])
            barButtonItem = [DDBarButtonItem rightBarButtonItemWithTitle:(NSString*)item target:nil action:nil];
        else
            barButtonItem = [DDBarButtonItem middleBarButtonItemWithTitle:(NSString*)item target:nil action:nil];
        
        //create segmented control item
        DDSegmentedControlItem *segmentedControlItem = [[[DDSegmentedControlItem alloc] init] autorelease];
        segmentedControlItem.normalImage = barButtonItem.normalImage;
        segmentedControlItem.highlightedImage = barButtonItem.highlightedImage;
        segmentedControlItem.disabledImage = barButtonItem.disabledImage;
        
        //add images
        [itemsInternal addObject:segmentedControlItem];
    }
    
    //usual init
    if ((self = [super initWithItems:items]))
    {
        //save items
        items_ = [itemsInternal retain];
        
        //apply style
        self.segmentedControlStyle = UISegmentedControlStyleBar;
        
        //set dividers
        [self setDividerImage:[UIImage imageNamed:@"dd-segmented-divider-none-selected.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [self setDividerImage:[UIImage imageNamed:@"dd-segmented-divider-left-selected.png"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [self setDividerImage:[UIImage imageNamed:@"dd-segmented-divider-right-selected.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        //update items
        [self updateItems];
        
        //observe for change
        [self addTarget:self action:@selector(updateItems) forControlEvents:UIControlEventValueChanged];
    }
    
    return self;
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    //make super
    [super setSelectedSegmentIndex:selectedSegmentIndex];
    
    //update self
    [self updateItems];
}

- (void)dealloc
{
    [items_ release];
    [super dealloc];
}

@end
