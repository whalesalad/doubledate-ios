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

@interface DDBasicInfoViewController ()<RKRequestDelegate>

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
    //set params
    RKParams *params = [RKParams params];
    [params setValue:textFieldName.text forParam:@"first_name"];
    [params setValue:textFieldSurname.text forParam:@"last_name"];
    [params setValue:@"1987/09/09" forParam:@"birthday"];
    if (segmentedControlMale.selectedSegmentIndex == 0)
        [params setValue:@"male" forParam:@"gender"];
    else if (segmentedControlMale.selectedSegmentIndex == 1)
        [params setValue:@"female" forParam:@"gender"];
    if (segmentedControlSingle.selectedSegmentIndex == 0)
        [params setValue:[NSNumber numberWithBool:YES] forParam:@"single"];
    else if (segmentedControlMale.selectedSegmentIndex == 1)
        [params setValue:[NSNumber numberWithBool:NO] forParam:@"single"];
    if (segmentedControlLike.selectedSegmentIndex == 0)
        [params setValue:@"guys" forParam:@"interested_in"];
    else if (segmentedControlLike.selectedSegmentIndex == 1)
        [params setValue:@"girls" forParam:@"interested_in"];
    else if (segmentedControlLike.selectedSegmentIndex == 2)
        [params setValue:@"both" forParam:@"interested_in"];
    
    //create request
    NSURL *url = [NSURL URLWithString:@"http://dbld8.herokuapp.com/users"];
    RKRequest *request = [[RKRequest alloc] initWithURL:url];
    request.method = RKRequestMethodPOST;
    request.params = params;
    request.delegate = self;
    
    //show hud
    [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
    
    //send
    [request sendAsynchronously];
}

#pragma mark -
#pragma comment IB

#pragma mark -
#pragma mark RKRequest

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    //check response code
    if (response.statusCode == 200)
    {
        //hide hude
        [self hideHud:YES];
    }
    else
    {
        //create error
        NSError *error = [NSError errorWithDomain:@"RKDomain" code:-1 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Wrong response code", nil) forKey:NSLocalizedDescriptionKey]];

        //handle error
        [self request:request didFailLoadWithError:error];
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)requestDidCancelLoad:(RKRequest *)request
{
    //hide hud
    [self hideHud:YES];
}

- (void)requestDidTimeout:(RKRequest *)request
{
    //hide hud
    [self hideHud:YES];
}

@end
