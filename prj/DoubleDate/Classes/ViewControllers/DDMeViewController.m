//
//  DDMeViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDMeViewController.h"
#import "DDUser.h"

@interface DDMeViewController ()

@end

@implementation DDMeViewController

@synthesize user;
@synthesize labelTitle;

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
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"My Profile", nil);
    
    //add right button
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStyleDone target:self action:@selector(editTouched:)] autorelease];
    
    //set title
    labelTitle.text = [NSString stringWithFormat:@"%@ %@", [user.firstName capitalizedString], [user.lastName capitalizedString]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [labelTitle release], labelTitle = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [user release];
    [labelTitle release];
    [super dealloc];
}

#pragma mark -
#pragma comment other

- (void)editTouched:(id)sender
{
}

@end
