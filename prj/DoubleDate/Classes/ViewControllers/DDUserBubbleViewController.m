//
//  DDUserBubbleViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 12/24/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDUserBubbleViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DDUserBubbleViewController ()

@end

@implementation DDUserBubbleViewController

@synthesize labelTitle;
@synthesize labelLocation;
@synthesize imageViewGender;
@synthesize photoView;
@synthesize textView;
@synthesize viewInterests;
@synthesize viewMain;
@synthesize labelIceBreakers;
@synthesize viewBottom;
@synthesize pageControl;
@synthesize viewEffects;

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
    self.viewInterests.backgroundColor = [UIColor clearColor];
    self.viewBottom.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
    
    // shadow and border for bubble
    self.viewEffects.layer.shadowColor = [UIColor blackColor].CGColor;
    self.viewEffects.layer.shadowOpacity = 1.0f;
    self.viewEffects.layer.shadowOffset = CGSizeMake(0, 2);
    self.viewEffects.layer.shadowRadius = 20;
    
    self.viewEffects.layer.borderWidth = 1;
    self.viewEffects.layer.borderColor = [UIColor blackColor].CGColor;
    
    // viewImagesContainer.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1].CGColor;
    // viewImagesContainer.layer.borderWidth = 1;
    
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
    [viewInterests release];
    [viewMain release];
    [labelIceBreakers release];
    [viewBottom release];
    [pageControl release];
    [viewEffects release];
    [super dealloc];
}

@end
