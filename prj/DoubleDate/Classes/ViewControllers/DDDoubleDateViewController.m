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
#import "DDImageView.h"
#import "DDImage.h"
#import "DDShortUser.h"

@interface DDDoubleDateViewController ()

@end

@implementation DDDoubleDateViewController

@synthesize doubleDate;

@synthesize scrollView;

@synthesize labelLocationMain;
@synthesize labelLocationDetailed;
@synthesize labelDayTime;

@synthesize containerTextView;
@synthesize containerTopImageView;
@synthesize containerBottomImageView;

@synthesize textView;

@synthesize containerPhotos;

@synthesize imageViewUserLeft;
@synthesize imageViewUserRight;

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
    
    //apply autoresizing mask
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    //customize text
    DD_F_HEADER_MAIN(self.labelLocationMain);
    DD_F_HEADER_DETAILED(self.labelLocationDetailed);
    DD_F_HEADER_MAIN(self.labelDayTime);
    DD_F_TEXT(self.textView);
    
    //fill data
    self.labelLocationMain.text = [DDLocationTableViewCell mainTitleForLocation:self.doubleDate.location];
    self.labelLocationDetailed.text = [DDLocationTableViewCell detailedTitleForLocation:self.doubleDate.location];
    self.labelDayTime.text = [DDCreateDoubleDateViewController titleForDDDay:self.doubleDate.dayPref ddTime:self.doubleDate.timePref];
    self.textView.text = [self.doubleDate details];
    
    //check if we should expand text view and scroll view
    CGSize newSizeOfTextView = self.textView.contentSize;
    if (newSizeOfTextView.height > self.textView.frame.size.height)
    {
        CGFloat dh = newSizeOfTextView.height - self.textView.frame.size.height;
        self.containerTextView.frame = CGRectMake(self.containerTextView.frame.origin.x, self.containerTextView.frame.origin.y, self.containerTextView.frame.size.width, self.containerTextView.frame.size.height+dh);
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height+dh);
        self.containerPhotos.frame = CGRectMake(self.containerPhotos.frame.origin.x, self.containerPhotos.frame.origin.y+dh, self.containerPhotos.frame.size.width, self.containerPhotos.frame.size.height);
    }
    
    //add images
    self.containerTopImageView.image = [[UIImage imageNamed:@"dd-indented-text-background-top.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 0, 1, 0)];
    self.containerBottomImageView.image = [UIImage imageNamed:@"dd-indented-text-background-bottom.png"];
    
    //load photos
    [self.imageViewUserLeft reloadFromUrl:[NSURL URLWithString:self.doubleDate.user.photo.downloadUrl]];
    self.imageViewUserLeft.contentMode = UIViewContentModeScaleAspectFill;
    [self.imageViewUserLeft applyMask:[UIImage imageNamed:@"dd-user-photo-mask.png"]];
    [self.imageViewUserRight reloadFromUrl:[NSURL URLWithString:self.doubleDate.wing.photo.downloadUrl]];
    [self.imageViewUserRight applyMask:[UIImage imageNamed:@"dd-user-photo-mask.png"]];
    self.imageViewUserRight.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)viewDidUnload
{
    [scrollView release], scrollView = nil;
    [labelLocationMain release], labelLocationMain = nil;
    [labelLocationDetailed release], labelLocationDetailed = nil;
    [labelDayTime release], labelDayTime = nil;
    [containerTextView release], containerTextView = nil;
    [containerTopImageView release], containerTopImageView = nil;
    [containerBottomImageView release], containerBottomImageView = nil;
    [textView release], textView = nil;
    [containerPhotos release], containerPhotos = nil;
    [imageViewUserLeft release], imageViewUserLeft = nil;
    [imageViewUserRight release], imageViewUserRight = nil;
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
    [containerTextView release];
    [containerTopImageView release];
    [containerBottomImageView release];
    [textView release];
    [containerPhotos release];
    [imageViewUserLeft release];
    [imageViewUserRight release];
    [super dealloc];
}

@end
