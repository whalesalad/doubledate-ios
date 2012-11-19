//
//  DDDoubleDateViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 11/16/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDateViewController.h"
#import "DDDoubleDate.h"
#import "DDLocationTableViewCell.h"
#import "DDCreateDoubleDateViewController.h"

@interface DDDoubleDateViewController ()

@end

@implementation DDDoubleDateViewController

@synthesize doubleDate;

@synthesize scrollView;

@synthesize labelLocationMain;
@synthesize labelLocationDetailed;
@synthesize labelDayTime;

- (id)initWithDoubleDate:(DDDoubleDate*)doubleDate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set navigation item
    self.navigationItem.title = [self.doubleDate title];
    
    //customize text
    DD_F_HEADER_MAIN(self.labelLocationMain);
    DD_F_HEADER_DETAILED(self.labelLocationDetailed);
    DD_F_HEADER_MAIN(self.labelDayTime);
    
    //fill data
    self.labelLocationMain.text = [DDLocationTableViewCell mainTitleForLocation:self.doubleDate.location];
    self.labelLocationDetailed.text = [DDLocationTableViewCell detailedTitleForLocation:self.doubleDate.location];
    self.labelDayTime.text = [DDCreateDoubleDateViewController titleForDDDay:self.doubleDate.dayPref ddTime:self.doubleDate.timePref];
}

- (void)viewDidUnload
{
    [scrollView release], scrollView = nil;
    [labelLocationMain release], labelLocationMain = nil;
    [labelLocationDetailed release], labelLocationDetailed = nil;
    [labelDayTime release], labelDayTime = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [doubleDate release];
    [scrollView release];
    [labelLocationMain release];
    [labelLocationDetailed release];
    [labelDayTime release];
    [super dealloc];
}

@end
