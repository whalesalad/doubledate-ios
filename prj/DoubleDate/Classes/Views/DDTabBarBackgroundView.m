//
//  DDTabBarBackgroundView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 1/8/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDTabBarBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

#define ICON_NORMAL_TAG 1
#define ICON_SELECTED_TAG 2

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
            
            //apply needed image
            NSString *imageName = nil;
            switch (i) {
                case 0:
                    if (self.selectedTab == i)
                        imageName = @"tab-bg-me-selected.png";
                    else if (self.selectedTab == i+1)
                        imageName = @"tab-bg-me-right-is-selected.png";
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
            
            //update selected state
            [[imageView viewWithTag:ICON_NORMAL_TAG] setHidden:self.selectedTab == i];
            [[imageView viewWithTag:ICON_SELECTED_TAG] setHidden:self.selectedTab != i];
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
            //add image view
            UIImageView *imageView = [[[UIImageView alloc] init] autorelease];
            imageView.frame = CGRectMake(i * self.frame.size.width / 4, 0, self.frame.size.width / 4, self.frame.size.height);
            [self addSubview:imageView];
            [imageViews_ addObject:imageView];
            
            //add icon
            UIImageView *iconNormal = [[[UIImageView alloc] initWithImage:nil] autorelease];
            iconNormal.hidden = YES;
            iconNormal.center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2);
            iconNormal.tag = ICON_NORMAL_TAG;
            [imageView addSubview:iconNormal];
            
            //add icon
            UIImageView *iconSelected = [[[UIImageView alloc] initWithImage:nil] autorelease];
            iconSelected.hidden = YES;
            iconSelected.center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2);
            iconSelected.tag = ICON_SELECTED_TAG;
            [imageView addSubview:iconSelected];
        }
        
        //update tabs
        [self updateTabs];
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, -2);
        self.layer.shadowOpacity = 0.5f;
        
        // add only a top black border
        CALayer *topBorder = [CALayer layer];
        topBorder.frame = CGRectMake(0.0f, -1.0f, self.frame.size.width, 1.0f);
        topBorder.backgroundColor = [UIColor blackColor].CGColor;
        [self.layer addSublayer:topBorder];

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

- (void)applyIcon:(UIImage*)icon forImageView:(UIImageView*)imageView
{
    // icon offset, it looks good right now.
    CGPoint iconOffset = CGPointMake(0, -1);
    imageView.image = icon;
    imageView.frame = CGRectMake(0, 0, icon.size.width, icon.size.height);
    imageView.center = CGPointMake(imageView.superview.frame.size.width/2+iconOffset.x, imageView.superview.frame.size.height/2+iconOffset.y);
}

- (void)setFinishedSelectedImage:(UIImage *)selectedImage withFinishedUnselectedImage:(UIImage *)unselectedImage forTab:(NSInteger)tab
{
    assert(tab < [imageViews_ count]);
    [self applyIcon:unselectedImage forImageView:(UIImageView*)[[imageViews_ objectAtIndex:tab] viewWithTag:ICON_NORMAL_TAG]];
    [self applyIcon:selectedImage forImageView:(UIImageView*)[[imageViews_ objectAtIndex:tab] viewWithTag:ICON_SELECTED_TAG]];
}

- (void)dealloc
{
    [imageViews_ release];
    [super dealloc];
}

@end
