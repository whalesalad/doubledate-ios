//
//  DDUserLocation.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAPIObject.h"

@interface DDPlacemark : DDAPIObject

@property(nonatomic, retain) NSString *country;
@property(nonatomic, retain) NSString *adminCode;
@property(nonatomic, retain) NSString *adminName;
@property(nonatomic, retain) NSNumber *latitude;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSNumber *identifier;
@property(nonatomic, retain) NSNumber *facebookId;
@property(nonatomic, retain) NSNumber *longitude;
@property(nonatomic, retain) NSString *distance;
@property(nonatomic, retain) NSString *locality;

@end
