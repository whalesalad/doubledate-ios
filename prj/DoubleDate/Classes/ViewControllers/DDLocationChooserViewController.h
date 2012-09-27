//
//  DDLocationChooserViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/24/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"
#import "DDLocationPickerViewController.h"
#import <CoreLocation/CoreLocation.h>

@class DDAPIController;

@interface DDLocationChooserViewController : DDViewController
{
    NSArray *placemarks_;
    DDAPIController *apiController_;
}

@property(nonatomic, retain) CLLocation *location;

@property(nonatomic, assign) id<DDLocationPickerViewControllerDelegate> delegate;

@property(nonatomic, retain) IBOutlet UITableView *tableView;

@end