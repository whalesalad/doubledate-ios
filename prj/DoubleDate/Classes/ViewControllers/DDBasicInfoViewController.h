//
//  DDBasicInfoViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"
#import "JSTokenField.h"

@protocol FBGraphUser;
@class DDUserLocation;

@interface DDBasicInfoViewController : DDViewController
{
}

@property(nonatomic, retain) id<FBGraphUser> facebookUser;

@property(nonatomic, retain) DDUserLocation *userLocation;

@property(nonatomic, retain) IBOutlet UITextField *textFieldName;
@property(nonatomic, retain) IBOutlet UITextField *textFieldSurname;
@property(nonatomic, retain) IBOutlet UITextField *textFieldBirth;

@property(nonatomic, retain) IBOutlet UISegmentedControl *segmentedControlMale;
@property(nonatomic, retain) IBOutlet UISegmentedControl *segmentedControlLike;
@property(nonatomic, retain) IBOutlet UISegmentedControl *segmentedControlSingle;

@property(nonatomic, retain) IBOutlet UILabel *labelLocation;

- (IBAction)locationTouched:(id)sender;

@end
