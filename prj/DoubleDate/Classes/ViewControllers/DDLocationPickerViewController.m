//
//  DDLocationPickerViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDLocationPickerViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "DDLocationChooserViewController.h"
#import "DDBarButtonItem.h"

@interface DDLocationPickerViewController ()

@end

@implementation DDLocationPickerViewController

@synthesize delegate;
@synthesize mapView;

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
    
    //add touch recognizer
    UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)] autorelease];
    [self.mapView addGestureRecognizer:tapRecognizer];
    
    //add right button
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Choose", nil) target:self action:@selector(chooseTouched:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;

    //add right button
    self.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Cancel", nil) target:self action:@selector(cancelTouched:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [mapView release], mapView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [mapView release];
    [super dealloc];
}

#pragma mark -
#pragma comment other

- (void)tap:(UITapGestureRecognizer*)sender
{
    //check for state
    if (sender.view == self.mapView && sender.state == UIGestureRecognizerStateRecognized)
    {
        //check if we have only one choice
        [self.mapView removeAnnotations:self.mapView.annotations];
            
        //save touch position
        CGPoint locationInView = [sender locationInView:sender.view];
        
        //extract coordinates
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:locationInView toCoordinateFromView:self.mapView];
        
        //add annotation
        MKPointAnnotation *annotation = [[[MKPointAnnotation alloc] init] autorelease];
        annotation.coordinate = coordinate;
        [self.mapView addAnnotation:annotation];
        
        //enable right button
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)chooseTouched:(id)sender
{
    //save locations
    NSMutableArray *locations = [NSMutableArray array];
    
    //check each annotation
    for (id<MKAnnotation> annotation in [self.mapView annotations])
    {
        if ([annotation isKindOfClass:[MKPointAnnotation class]])
        {
            CLLocation *location = [[[CLLocation alloc] initWithLatitude:[annotation coordinate].latitude longitude:[annotation coordinate].longitude] autorelease];
            [locations addObject:location];
        }
    }
    
    //check only one location
    if ([locations count] == 1)
    {
        DDLocationChooserViewController *locationChooserViewController = [[[DDLocationChooserViewController alloc] init] autorelease];
        locationChooserViewController.location = [locations lastObject];
        locationChooserViewController.delegate = self.delegate;
        locationChooserViewController.options = DDLocationSearchOptionsBoth;
        [self.navigationController pushViewController:locationChooserViewController animated:YES];
    }
}

- (void)cancelTouched:(id)sender
{
    [self.delegate locationPickerViewControllerDidCancel];
}

@end
