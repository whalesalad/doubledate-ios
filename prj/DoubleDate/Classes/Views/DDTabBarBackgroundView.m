//
//  DDTabBarBackgroundView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 1/8/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDTabBarBackgroundView.h"

@implementation DDTabBarBackgroundView

@synthesize numberOfTabs;
@synthesize selectedTab;

- (void)updateTabs
{
    //check 4 items
    if (self.numberOfTabs == 4)
    {
        //for each item
        for (int i = 0; i < 4; i++)
        {
            assert(i < [imageViews_ count]);
            
            //add image view
            UIImageView *imageView = [imageViews_ objectAtIndex:i];
            imageView.frame = CGRectMake(i * self.frame.size.width / 4, 0, self.frame.size.width / 4, self.frame.size.height);
            
            //apply needed image
            NSString *imageName = nil;
            switch (i) {
                case 0:
                    if (self.selectedTab == i)
                        imageName = @"tab-bg-me-selected.png";
                    else
                        imageName = @"tab-bg-me.png";
                    break;
                case 1:
                case 2:
                case 3:
                    if (self.selectedTab == i)
                        imageName = @"tab-bg-selected.png";
                    else if (self.selectedTab == i+1)
                        imageName = @"tab-bg-right-is-selected.png";
                    else
                        imageName = @"tab-bg-normal.png";
                    break;
                default:
                    break;
            }
            
            //apply needed image
            imageView.image = [UIImage imageNamed:imageName];
        }
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //add list
        imageViews_ = [[NSMutableArray alloc] init];
        
        //add image views
        for (int i = 0; i < 4; i++)
        {
            UIImageView *imageView = [[[UIImageView alloc] init] autorelease];
            imageView.tag = i;
            [self addSubview:imageView];
            [imageViews_ addObject:imageView];
        }
        
        //update tabs
        [self updateTabs];
    }
    return self;
}

- (void)setNumberOfTabs:(NSInteger)v
{
    numberOfTabs = v;
    [self updateTabs];
}

- (void)setSelectedTab:(NSInteger)v
{
    selectedTab = v;
    [self updateTabs];
}

- (void)dealloc
{
    [imageViews_ release];
    [super dealloc];
}

@end
