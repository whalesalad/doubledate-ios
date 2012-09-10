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
#import <RestKit/RestKit.h>
#import <SBJson/SBJson.h>
#import "DDTools.h"
#import "DDFacebookController.h"
#import "DDUser.h"
#import "DDBioViewController.h"

@interface DDBasicInfoViewController ()

@end

@implementation DDBasicInfoViewController

@synthesize facebookUser;
@synthesize fbBonusView;
@synthesize mainView;
@synthesize textFieldName;
@synthesize textFieldSurname;
@synthesize textFieldBirth;
@synthesize segmentedControlMale;
@synthesize segmentedControlLike;
@synthesize segmentedControlSingle;

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
    if (facebookUser)
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
    
    //check if user exist
    if (facebookUser)
    {
        //set name
        textFieldName.text = [facebookUser first_name];
        
        //set surname
        textFieldSurname.text = [facebookUser last_name];
        
        //set birthday
        if ([facebookUser birthday])
        {
            //get date
            NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
            [dateFormat setDateFormat:@"MM/dd/yyyy"];
            NSString *dateString = [facebookUser birthday];
            NSDate *date = [dateFormat dateFromString:dateString];

            //set date
            [dateFormat setDateFormat:@"yyyy-MM-dd"];
            textFieldBirth.text = [dateFormat stringFromDate:date];
        }
        
        //set gender
        if ([[facebookUser objectForKey:@"gender"] isEqualToString:@"male"])
            segmentedControlMale.selectedSegmentIndex = 0;
        else if ([[facebookUser objectForKey:@"gender"] isEqualToString:@"female"])
            segmentedControlMale.selectedSegmentIndex = 1;
        else
            segmentedControlMale.selectedSegmentIndex = -1;
        
        //save like
        segmentedControlLike.selectedSegmentIndex = -1;

        //save single status
        segmentedControlSingle.selectedSegmentIndex = -1;
    }
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
    [facebookUser release];
    [fbBonusView release];
    [mainView release];
    [textFieldName release];
    [textFieldSurname release];
    [textFieldBirth release];
    [segmentedControlMale release];
    [segmentedControlLike release];
    [segmentedControlSingle release];
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
    //save dictionary
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:textFieldName.text forKey:@"first_name"];
    [dictionary setObject:textFieldSurname.text forKey:@"last_name"];
    [dictionary setObject:textFieldBirth.text forKey:@"birthday"];
    if (segmentedControlSingle.selectedSegmentIndex == 0)
        [dictionary setObject:@"true" forKey:@"signle"];
    else if (segmentedControlSingle.selectedSegmentIndex == 1)
        [dictionary setObject:@"false" forKey:@"signle"];
    if (segmentedControlLike.selectedSegmentIndex == 0)
        [dictionary setObject:@"guys" forKey:@"interested_in"];
    else if (segmentedControlLike.selectedSegmentIndex == 1)
        [dictionary setObject:@"girls" forKey:@"interested_in"];
    else if (segmentedControlLike.selectedSegmentIndex == 2)
        [dictionary setObject:@"both" forKey:@"interested_in"];
    if (segmentedControlMale.selectedSegmentIndex == 0)
        [dictionary setObject:@"male" forKey:@"gender"];
    else if (segmentedControlMale.selectedSegmentIndex == 1)
        [dictionary setObject:@"female" forKey:@"gender"];
    
    //save new user
    DDUser *newUser = [[[DDUser alloc] initWithDictionary:dictionary] autorelease];
    
    //check for facebook
    if (facebookUser)
        newUser.facebookId = [facebookUser id];
    else
    {
        newUser.email = @"test_email@belluba.com";
        newUser.password = @"test";
    }
    
    //go next
    DDBioViewController *viewController = [[[DDBioViewController alloc] init] autorelease];
    viewController.user = newUser;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
