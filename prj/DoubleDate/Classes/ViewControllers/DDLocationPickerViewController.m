//
//  DDLocationPickerViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDLocationPickerViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface DDLocationPickerViewController ()

@end

@implementation DDLocationPickerViewController

@synthesize delegate;
@synthesize mapView;
@synthesize multiplyChoice;

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
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Choose", nil) style:UIBarButtonItemStyleDone target:self action:@selector(chooseTouched:)] autorelease];
    
    //add right button
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleDone target:self action:@selector(cancelTouched:)] autorelease];
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
        if (!self.multiplyChoice)
            [self.mapView removeAnnotations:self.mapView.annotations];
            
        //save touch position
        CGPoint locationInView = [sender locationInView:sender.view];
        
        //extract coordinates
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:locationInView toCoordinateFromView:self.mapView];
        
        //add annotation
        MKPointAnnotation *annotation = [[[MKPointAnnotation alloc] init] autorelease];
        annotation.coordinate = coordinate;
        [self.mapView addAnnotation:annotation];
    }
}

- (void)locationsDecodingFinished:(NSArray*)placemarks
{
    NSLog(@"FOUND %d", [placemarks count]);
}

- (void)chooseTouched:(id)sender
{
    //save locations
    NSMutableArray *locations = [NSMutableArray array];
    
    //check each annotation
    for (id<MKAnnotation> annotation in [self.mapView annotations])
    {
        CLLocation *location = [[[CLLocation alloc] initWithLatitude:[annotation coordinate].latitude longitude:[annotation coordinate].longitude] autorelease];
        [locations addObject:location];
    }
    
    //save placemarks
    __block NSMutableArray *totalPlacemarks = [NSMutableArray array];
        
    //save number of locatins
    __block NSInteger numberOfLocationsToDecode = [locations count];
    
    //create geo coder
    for (CLLocation *location in locations)
    {
        CLGeocoder *geoCoder = [[[CLGeocoder alloc] init] autorelease];
        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                        
            //decrease the number of locations
            numberOfLocationsToDecode--;
            
            //add placemarks
            [totalPlacemarks addObjectsFromArray:placemarks];
            
            //check for finish
            if (numberOfLocationsToDecode == 0)
                [self locationsDecodingFinished:placemarks];
        }];
    }
}

- (void)cancelTouched:(id)sender
{
    [self.delegate locationPickerViewControllerDidCancel];
}

@end
