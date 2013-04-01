//
//  DDSegmentedControl.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDSegmentedControl.h"
#import "DDTools.h"
#import "DDBarButtonItem.h"

@implementation DDSegmentedControlItem

@synthesize title;
@synthesize width;

+ (id)itemWithTitle:(NSString*)title
{
    DDSegmentedControlItem *ret = [[[DDSegmentedControlItem alloc] init] autorelease];
    ret.title = title;
    return ret;
}

+ (id)itemWithTitle:(NSString*)title width:(CGFloat)width
{
    DDSegmentedControlItem *ret = [[[DDSegmentedControlItem alloc] init] autorelease];
    ret.title = title;
    ret.width = width;
    return ret;
}

- (void)dealloc
{
    [title release];
    [super dealloc];
}

@end

@interface DDSegmentedControlItemImages : NSObject

@property(nonatomic, retain) UIImage *normalImage;
@property(nonatomic, retain) UIImage *highlightedImage;
@property(nonatomic, retain) UIImage *disabledImage;

@end

@implementation DDSegmentedControlItemImages

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
        DDSegmentedControlItemImages *item = [items_ objectAtIndex:i];
        
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
    return [self initWithItems:items style:DDSegmentedControlStyleSmall];
}

- (id)initWithItems:(NSArray *)items style:(DDSegmentedControlStyle)style
{
    //save items for internal representation
    NSMutableArray *itemsInternal = [NSMutableArray array];
    NSMutableArray *itemsStrings = [NSMutableArray array];
    for (NSObject *item in items)
    {
        //support only needed objects
        assert([item isKindOfClass:[NSString class]] || [item isKindOfClass:[DDSegmentedControlItem class]]);
        
        //save parameters
        NSString *itemTitle = nil;
        if ([item isKindOfClass:[NSString class]])
            itemTitle = (NSString*)item;
        if ([item isKindOfClass:[DDSegmentedControlItem class]])
            itemTitle = [(DDSegmentedControlItem*)item title];
        CGFloat itemWidth = 0;
        if ([item isKindOfClass:[DDSegmentedControlItem class]])
            itemWidth = [(DDSegmentedControlItem*)item width];
        
        //add title
        [itemsStrings addObject:itemTitle];

        //add bar button items
        DDBarButtonItem *barButtonItem = nil;
        if (style == DDSegmentedControlStyleSmall)
        {
            if (item == [items objectAtIndex:0] && item != [items lastObject])
                barButtonItem = [DDBarButtonItem leftBarButtonItemWithTitle:itemTitle target:nil action:nil];
            else if (item == [items lastObject] && item != [items objectAtIndex:0])
                barButtonItem = [DDBarButtonItem rightBarButtonItemWithTitle:itemTitle target:nil action:nil];
            else
                barButtonItem = [DDBarButtonItem middleBarButtonItemWithTitle:itemTitle target:nil action:nil];
        }
        else if (style == DDSegmentedControlStyleLarge)
        {
            if (item == [items objectAtIndex:0] && item != [items lastObject])
                barButtonItem = [DDBarButtonItem leftLargeBarButtonItemWithTitle:itemTitle target:nil action:nil size:itemWidth];
            else if (item == [items lastObject] && item != [items objectAtIndex:0])
                barButtonItem = [DDBarButtonItem rightLargeBarButtonItemWithTitle:itemTitle target:nil action:nil size:itemWidth];
            else
                barButtonItem = [DDBarButtonItem middleLargeBarButtonItemWithTitle:itemTitle target:nil action:nil size:itemWidth];
        }
        
        //create segmented control item
        DDSegmentedControlItemImages *segmentedControlItem = [[[DDSegmentedControlItemImages alloc] init] autorelease];
        segmentedControlItem.normalImage = barButtonItem.normalImage;
        segmentedControlItem.highlightedImage = barButtonItem.highlightedImage;
        segmentedControlItem.disabledImage = barButtonItem.disabledImage;
        
        //add images
        [itemsInternal addObject:segmentedControlItem];
    }
    
    //usual init
    if ((self = [super initWithItems:itemsStrings]))
    {
        //save items
        items_ = [itemsInternal retain];
        
        //apply style
        self.segmentedControlStyle = UISegmentedControlStyleBar;
        
        //set dividers
        if (style == DDSegmentedControlStyleSmall)
        {
            [self setDividerImage:[UIImage imageNamed:@"dd-segmented-divider-none-selected.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [self setDividerImage:[UIImage imageNamed:@"dd-segmented-divider-left-selected.png"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [self setDividerImage:[UIImage imageNamed:@"dd-segmented-divider-right-selected.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        }
        else if (style == DDSegmentedControlStyleLarge)
        {
            [self setDividerImage:[UIImage imageNamed:@"large-divider-none-selected.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [self setDividerImage:[UIImage imageNamed:@"large-divider-left-selected.png"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [self setDividerImage:[UIImage imageNamed:@"large-divider-right-selected.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        }
        
        //apply clear background
        [self setBackgroundImage:[DDTools clearImageOfSize:CGSizeMake(1, [self dividerImageForLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault].size.height)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
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
