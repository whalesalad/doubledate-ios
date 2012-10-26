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
#import "DDImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface DDCreateDoubleDateViewController () <DDWingsViewControllerDelegate>

@property(nonatomic, retain) DDShortUser *wing;

@end

@implementation DDCreateDoubleDateViewController

@synthesize buttonWing;
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
    
    //apply text
    self.buttonWing.placeholder = NSLocalizedString(@"Choose a wing...", nil);
}

- (void)viewDidUnload
{
    [buttonWing release], buttonWing = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [buttonWing release];
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
    
    //apply blank image by default
    self.buttonWing.normalIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank-wingman-icon.png"]] autorelease];
    
    //apply wing
    if (wing)
    {
        //load image
        if ([[wing photo] downloadUrl])
        {
            DDImageView *imageView = [[[DDImageView alloc] init] autorelease];
            imageView.frame = CGRectMake(0, 0, 34, 34);
            imageView.layer.cornerRadius = 17;
            imageView.layer.masksToBounds = YES;
            [imageView reloadFromUrl:[NSURL URLWithString:[[wing photo] downloadUrl]]];
            self.buttonWing.normalIcon = imageView;
        }
        
        //apply text
        self.buttonWing.text = [wing fullName];
    }
}

#pragma mark -
#pragma comment DDWingsViewControllerDelegate

- (void)wingsViewController:(DDWingsViewController*)viewController didSelectUser:(DDShortUser*)user
{
    [self setWing:user];
    [viewController.navigationController popViewControllerAnimated:YES];
}

@end
