//
//  DDLocationPickerViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"
#import <MapKit/MapKit.h>

@interface DDLocationPickerViewController : DDViewController<MKMapViewDelegate>

@property(nonatomic, assign) BOOL multiplyChoice;

@property(nonatomic, retain) IBOutlet MKMapView *mapView;

@end
