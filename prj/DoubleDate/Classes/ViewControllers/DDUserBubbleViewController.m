//
//  DDUserBubbleViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 12/24/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDUserBubbleViewController.h"
#import "DDPhotoView.h"

@interface DDUserBubbleViewController ()

@end

@implementation DDUserBubbleViewController

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
    
    //unset all backgrounds
    self.labelTitle.backgroundColor = [UIColor clearColor];
    self.labelLocation.backgroundColor = [UIColor clearColor];
    self.imageViewGender.backgroundColor = [UIColor clearColor];
    self.imageViewGradient.backgroundColor = [UIColor clearColor];
    self.photoView.backgroundColor = [UIColor clearColor];
    self.textView.backgroundColor = [UIColor clearColor];
    self.viewInterests.backgroundColor = [UIColor clearColor];
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
