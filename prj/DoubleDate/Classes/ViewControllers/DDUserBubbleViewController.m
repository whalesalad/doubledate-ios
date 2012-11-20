//
//  DDUserBubbleViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 11/20/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDUserBubbleViewController.h"
#import "DDUser.h"
#import "DDLocationTableViewCell.h"
#import "DDPlacemark.h"

@interface DDUserBubbleViewController ()

@end

@implementation DDUserBubbleViewController

@synthesize user;

@synthesize labelTitle;
@synthesize imageViewGender;
@synthesize labelLocation;
@synthesize textViewInfo;

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
    
    //fill data
    self.labelTitle.text = [self.user firstName];
    self.labelLocation.text = self.user.location.name;
    self.textViewInfo.text = self.user.bio;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [labelTitle release], labelTitle = nil;
    [imageViewGender release], imageViewGender = nil;
    [labelLocation release], labelLocation = nil;
    [textViewInfo release], textViewInfo = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [user release];
    [labelTitle release];
    [imageViewGender release];
    [labelLocation release];
    [textViewInfo release];
    [super dealloc];
}

@end
