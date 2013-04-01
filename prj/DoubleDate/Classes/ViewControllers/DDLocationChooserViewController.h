//
//  DDLocationChooserViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/24/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTableViewController.h"
#import "DDLocationPickerViewController.h"
#import "DDAPIController.h"
#import <CoreLocation/CoreLocation.h>

@class DDAPIController;
@class DDPlacemark;

@interface DDLocationChooserViewController : DDTableViewController
{
    NSArray *placemarks_;
    NSMutableArray *selectedLocations_;
}

@property(nonatomic, retain) DDPlacemark *ddLocation;
@property(nonatomic, retain) CLLocation *clLocation;
@property(nonatomic, retain) NSString *query;
@property(nonatomic, assign) NSInteger distance;

@property(nonatomic, assign) DDLocationSearchOptions options;

@property(nonatomic, assign) id<DDLocationPickerViewControllerDelegate> delegate;

@property(nonatomic, assign) BOOL allowsMultiplyChoice;

@end
