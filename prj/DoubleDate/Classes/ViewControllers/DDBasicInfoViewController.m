//
//  DDBasicInfoViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDBasicInfoViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DDAppDelegate.h"

@interface DDBasicInfoViewController ()

@end

@implementation DDBasicInfoViewController

@synthesize user;
@synthesize fbBonusView;
@synthesize mainView;
@synthesize textFieldName;
@synthesize textFieldSurname;
@synthesize textFieldBirth;
@synthesize segmentedControlMale;
@synthesize segmentedControlLike;
@synthesize segmentedControlSingle;
@synthesize textFieldLocations;

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
    self.navigationItem.title = NSLocalizedString(@"Basic Info", nil);
    
    //add right button
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil) style:UIBarButtonItemStyleDone target:self action:@selector(nextTouched:)] autorelease];
    
    //check for facebook user
    if (user)
    {
        //save main window
        UIWindow *window = [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] window];
        
        //create main view
        UIView *viewToAdd = [[[UIView alloc] initWithFrame:[window bounds]] autorelease];
        viewToAdd.hidden = YES;
        [window addSubview:viewToAdd];
        
        //add dim
        UIView *dim = [[[UIView alloc] initWithFrame:viewToAdd.bounds] autorelease];
        dim.alpha = 0.3f;
        dim.backgroundColor = [UIColor blackColor];
        [viewToAdd addSubview:dim];
        
        //add image
        UIView *image = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)] autorelease];
        image.backgroundColor = [UIColor greenColor];
        image.center = dim.center;
        [viewToAdd addSubview:image];
        
        //add button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(0, 0, 60, 30);
        button.center = CGPointMake(dim.center.x, dim.center.y + 30);
        [button setTitle:NSLocalizedString(@"Continue", nil) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(continueTouched:) forControlEvents:UIControlEventTouchUpInside];
        [viewToAdd addSubview:button];
        
        //apply main view
        self.viewAfterAppearing = viewToAdd;
    }
    else
    {
        //move main view
        mainView.frame = CGRectMake(mainView.frame.origin.x, mainView.frame.origin.y - fbBonusView.frame.size.height, mainView.frame.size.width, mainView.frame.size.height);
    }
    
    NSLog(@"%@", user);
        
    //fill the data
    textFieldName.text = [user first_name];
    textFieldSurname.text = [user last_name];
    textFieldBirth.text = [user birthday];
    segmentedControlMale.selected = YES;
    if ([[user objectForKey:@"gender"] isEqualToString:@"male"])
        segmentedControlMale.selectedSegmentIndex = 0;
    else
        segmentedControlMale.selectedSegmentIndex = 1;
    segmentedControlLike.selectedSegmentIndex = -1;
    segmentedControlSingle.selectedSegmentIndex = -1;
    textFieldLocations.text = [[user objectForKey:@"location"] objectForKey:@"name"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [fbBonusView release], fbBonusView = nil;
    [mainView release], mainView = nil;
    [textFieldName release], textFieldName = nil;
    [textFieldSurname release], textFieldSurname = nil;
    [textFieldBirth release], textFieldBirth = nil;
    [segmentedControlMale release], segmentedControlMale = nil;
    [segmentedControlLike release], segmentedControlLike = nil;
    [segmentedControlSingle release], segmentedControlSingle = nil;
    [textFieldLocations release], textFieldLocations = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

- (void)dealloc
{
    [user release];
    [fbBonusView release];
    [mainView release];
    [textFieldName release];
    [textFieldSurname release];
    [textFieldBirth release];
    [segmentedControlMale release];
    [segmentedControlLike release];
    [segmentedControlSingle release];
    [textFieldLocations release];
    [super dealloc];
}

#pragma mark -
#pragma comment other

- (void)continueTouched:(id)sender
{
    [self.viewAfterAppearing removeFromSuperview];
    self.viewAfterAppearing = nil;
}

- (void)nextTouched:(id)sender
{
    
}

#pragma mark -
#pragma comment IB

@end
