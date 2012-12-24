//
//  DDDoubleDateBubbleViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 12/24/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDateBubbleViewController.h"

@interface DDDoubleDateBubbleViewController ()

@end

@implementation DDDoubleDateBubbleViewController

@synthesize labelTitle;
@synthesize labelLocation;
@synthesize imageViewGender;
@synthesize imageViewGradient;
@synthesize photoView;
@synthesize textView;
@synthesize viewInterests;

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
    [imageViewGradient release];
    [photoView release];
    [textView release];
    [viewInterests release];
    [super dealloc];
}

@end
