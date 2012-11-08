//
//  DDLocationChooserViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/24/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"
#import "DDLocationPickerViewController.h"
#import "DDAPIController.h"
#import <CoreLocation/CoreLocation.h>

@class DDAPIController;
@class DDPlacemark;

@interface DDLocationChooserViewController : DDViewController
{
    NSArray *placemarks_;
    NSMutableArray *selectedLocations_;
}

@property(nonatomic, retain) DDPlacemark *ddLocation;
@property(nonatomic, retain) CLLocation *clLocation;

@property(nonatomic, assign) DDLocationSearchOptions options;

@property(nonatomic, assign) id<DDLocationPickerViewControllerDelegate> delegate;

@property(nonatomic, assign) BOOL allowsMultiplyChoice;

@property(nonatomic, retain) IBOutlet UITableView *tableView;

@end
