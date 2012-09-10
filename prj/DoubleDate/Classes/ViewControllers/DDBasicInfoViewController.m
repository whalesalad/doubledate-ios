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

@interface DDBasicInfoViewController ()<UITextFieldDelegate>

@end

@implementation DDBasicInfoViewController

@synthesize facebookUser;
@synthesize textFieldName;
@synthesize textFieldSurname;
@synthesize textFieldBirth;
@synthesize segmentedControlMale;
@synthesize segmentedControlLike;
@synthesize segmentedControlSingle;
@synthesize tokenFieldLocation;

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
    
    //set delegates
    textFieldName.delegate = self;
    textFieldSurname.delegate = self;
    textFieldBirth.delegate = self;
    tokenFieldLocation.textField.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [textFieldName release], textFieldName = nil;
    [textFieldSurname release], textFieldSurname = nil;
    [textFieldBirth release], textFieldBirth = nil;
    [segmentedControlMale release], segmentedControlMale = nil;
    [segmentedControlLike release], segmentedControlLike = nil;
    [segmentedControlSingle release], segmentedControlSingle = nil;
    [tokenFieldLocation release], tokenFieldLocation = nil;
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
    [textFieldName release];
    [textFieldSurname release];
    [textFieldBirth release];
    [segmentedControlMale release];
    [segmentedControlLike release];
    [segmentedControlSingle release];
    [tokenFieldLocation release];
    [super dealloc];
}

#pragma mark -
#pragma comment other

- (void)nextTouched:(id)sender
{
    //fill user data
    DDUser *newUser = [[[DDUser alloc] init] autorelease];
    newUser.firstName = textFieldName.text;
    newUser.lastName = textFieldSurname.text;
    newUser.birthday = textFieldBirth.text;
    if (segmentedControlSingle.selectedSegmentIndex == 0)
        newUser.single = @"true";
    else if (segmentedControlSingle.selectedSegmentIndex == 1)
        newUser.single = @"false";
    if (segmentedControlLike.selectedSegmentIndex == 0)
        newUser.interestedIn = @"guys";
    else if (segmentedControlLike.selectedSegmentIndex == 1)
        newUser.interestedIn = @"girls";
    else if (segmentedControlLike.selectedSegmentIndex == 2)
        newUser.interestedIn = @"both";
    if (segmentedControlMale.selectedSegmentIndex == 0)
        newUser.gender = @"male";
    else if (segmentedControlMale.selectedSegmentIndex == 1)
        newUser.gender = @"female";
    
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

#pragma mark -
#pragma comment UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.tokenFieldLocation.textField)
    {
        for (NSString *text in [textField.text componentsSeparatedByString:@" "])
            [self.tokenFieldLocation addTokenWithTitle:text representedObject:nil];
    }
}

@end
