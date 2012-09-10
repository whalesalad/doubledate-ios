//
//  DDInterestsViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/10/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDInterestsViewController.h"
#import "DDUser.h"
#import "DDAPIController.h"

@interface DDInterestsViewController ()<DDAPIControllerDelegate>

@end

@implementation DDInterestsViewController

@synthesize user;
@synthesize tokenFieldInterests;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        //add observer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:nil];
        
        controller_ = [[DDAPIController alloc] init];
        controller_.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"Your Interests", nil);
    
    //add right button
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil) style:UIBarButtonItemStyleDone target:self action:@selector(nextTouched:)] autorelease];
    
    //add token title
    tokenFieldInterests.label.text = NSLocalizedString(@"Interests:", nil);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [tokenFieldInterests release], tokenFieldInterests = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [user release];
    [tokenFieldInterests release];
    controller_.delegate = nil;
    [controller_ release];
    [super dealloc];
}

#pragma mark -
#pragma comment other

- (void)nextTouched:(id)sender
{
    //add interests
    NSMutableString *interests = [NSMutableString string];
    NSArray *tokens = self.tokenFieldInterests.tokens;
    for (NSString *interest in tokens)
    {
        [interests appendString:interest];
        if (interest != [tokens lastObject])
            [interests appendString:@" "];
    }

    //save interests
    self.user.interests = interests;
    
    //show hud
    [self showHudWithText:NSLocalizedString(@"Creating", nil) animated:YES];
    
    //create user
    [controller_ createUser:self.user];
}

- (void)textFieldTextDidChangeNotification:(NSNotification*)notification
{
    if ([notification object] == self.tokenFieldInterests.textField)
    {
        if ([self.tokenFieldInterests.textField.text rangeOfString:@" "].location != NSNotFound)
        {
            for (NSString *text in [self.tokenFieldInterests.textField.text componentsSeparatedByString:@" "])
                [self.tokenFieldInterests addTokenWithTitle:text representedObject:nil];
        }
    }
}

#pragma mark -
#pragma comment DDAPIControllerDelegate

- (void)createUserSucceed
{
    //hide hud
    [self hideHud:YES];
}

- (void)createUserDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
