//
//  DDCreateDoubleDateViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDCreateDoubleDateViewController.h"
#import "DDShortUser.h"
#import "DDWingsViewController.h"

@interface DDCreateDoubleDateViewController () <DDWingsViewControllerDelegate>

@property(nonatomic, retain) DDShortUser *wing;

@end

@implementation DDCreateDoubleDateViewController

@synthesize textFieldWing;
@synthesize wing;

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
    
    //apply wing
    self.wing = self.wing;
}

- (void)viewDidUnload
{
    [textFieldWing release], textFieldWing = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [textFieldWing release];
    [wing release];
    [super dealloc];
}

#pragma mark -
#pragma comment other

- (IBAction)wingTouched:(id)sender
{
    DDWingsViewController *wingsViewController = [[[DDWingsViewController alloc] init] autorelease];
    wingsViewController.delegate = self;
    wingsViewController.isSelectingMode = YES;
    [self.navigationController pushViewController:wingsViewController animated:YES];
}

- (void)setWing:(DDShortUser *)v
{
    //update value
    if (wing != v)
    {
        [wing release];
        wing = [v retain];
    }
    
    
    
    //apply needed image
    if (!wing)
    {
        //apply blank image
        self.textFieldWing.leftView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank-wingman-icon.png"]] autorelease];
        
        //apply left view mode
        self.textFieldWing.leftViewMode = UITextFieldViewModeAlways;
    }
}

#pragma mark -
#pragma comment DDWingsViewControllerDelegate

- (void)wingsViewController:(DDWingsViewController*)viewController didSelectUser:(DDShortUser*)user
{
    [self setWing:user];
}

@end
