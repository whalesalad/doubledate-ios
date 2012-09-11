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
#import "DDCompleteRegistrationViewController.h"
#import "JSTokenButton.h"

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
    NSMutableArray *interests = [NSMutableArray array];
    NSArray *tokens = self.tokenFieldInterests.tokens;
    for (JSTokenButton *button in tokens)
    {
        NSString *text = button.representedObject;
        text = [text stringByReplacingOccurrencesOfString:@"\u200B" withString:@""];
        [interests addObject:text];
    }
    
    //save interests
    if ([interests count])
        self.user.interests = interests;
    else
        self.user.interests = nil;
    
    //go to next
    DDCompleteRegistrationViewController *viewController = [[[DDCompleteRegistrationViewController alloc] init] autorelease];
    viewController.user = self.user;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)textFieldTextDidChangeNotification:(NSNotification*)notification
{
    if ([notification object] == self.tokenFieldInterests.textField)
    {
        if ([self.tokenFieldInterests.textField.text rangeOfString:@" "].location != NSNotFound)
        {
            for (NSString *text in [self.tokenFieldInterests.textField.text componentsSeparatedByString:@" "])
            {
                [self.tokenFieldInterests addTokenWithTitle:text representedObject:text];
            }
        }
    }
}

@end
