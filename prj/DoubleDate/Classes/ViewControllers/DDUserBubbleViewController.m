//
//  DDUserBubbleViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 12/24/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDUserBubbleViewController.h"
#import "DDImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface DDUserBubbleViewController ()

@end

@implementation DDUserBubbleViewController

@synthesize labelTitle;
@synthesize labelLocation;
@synthesize imageViewGender;
@synthesize photoView;
@synthesize textView;
@synthesize viewMain;
@synthesize viewBottom;
@synthesize pageControl;

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
    
    //unset all backgrounds
    self.labelTitle.backgroundColor = [UIColor clearColor];
    self.labelLocation.backgroundColor = [UIColor clearColor];
    self.imageViewGender.backgroundColor = [UIColor clearColor];
    self.textView.backgroundColor = [UIColor clearColor];
    self.viewBottom.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
    
    //customize bubble view
    self.textView.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.8f];
    self.textView.layer.borderWidth = 1;
    self.textView.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.3f].CGColor;
    self.textView.layer.cornerRadius = 6;
    self.photoView.layer.cornerRadius = 6;
    self.photoView.clipsToBounds = YES;
    
    self.view.layer.shouldRasterize = YES;
    self.view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [labelTitle release];
    [labelLocation release];
    [imageViewGender release];
    [photoView release];
    [textView release];
    [viewMain release];
    [viewBottom release];
    [pageControl release];
    [super dealloc];
}

@end
