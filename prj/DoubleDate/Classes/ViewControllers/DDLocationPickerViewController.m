//
//  DDLocationPickerViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDLocationPickerViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface DDLocationPickerActionSheet : UIActionSheet

@property(nonatomic, retain) NSObject *userData;

@end

@implementation DDLocationPickerActionSheet

@synthesize userData;

- (void)dealloc
{
    [userData release];
    [super dealloc];
}

@end

@interface DDLocationPickerViewController ()<UIActionSheetDelegate>

@end

@implementation DDLocationPickerViewController

@synthesize delegate;
@synthesize mapView;
@synthesize multiplyChoice;

- (UIView*)viewForHud
{
    return self.parentViewController.view;
}

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
    //hide hud
    [self hideHud:YES];
    
    //check if we need to select only one location
    if (!self.multiplyChoice)
    {
        //add action sheed
        DDLocationPickerActionSheet *actionSheet = [[[DDLocationPickerActionSheet alloc] initWithTitle:NSLocalizedString(@"Choose Location", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
        
        //set user data
        actionSheet.userData = placemarks;
        
        //add locations
        for (CLPlacemark *placemark in placemarks)
            [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea]];

        //show actions sheet
        [actionSheet showInView:self.navigationController.view];
    }
    else
        [self.delegate locationPickerViewControllerDidFoundPlacemarks:placemarks];
}

- (void)chooseTouched:(id)sender
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Loading", nil) animated:YES];
    
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
    
    //save placemarks
    NSMutableArray *totalPlacemarks = [NSMutableArray array];
        
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
                [self locationsDecodingFinished:totalPlacemarks];
        }];
    }
}

- (void)cancelTouched:(id)sender
{
    [self.delegate locationPickerViewControllerDidCancel];
}

#pragma mark -
#pragma comment UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex != buttonIndex && [actionSheet isKindOfClass:[DDLocationPickerActionSheet class]])
    {
        DDLocationPickerActionSheet *sheet = (DDLocationPickerActionSheet*)actionSheet;
        CLPlacemark *placemark = (CLPlacemark*)[(NSArray*)sheet.userData objectAtIndex:buttonIndex-1];
        [self.delegate locationPickerViewControllerDidFoundPlacemarks:[NSArray arrayWithObject:placemark]];
    }
}

@end
