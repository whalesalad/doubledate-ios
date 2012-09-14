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
@property(nonatomic, retain) NSString *latitude;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *identifier;
@property(nonatomic, retain) NSString *facebookId;
@property(nonatomic, retain) NSString *longitude;
@property(nonatomic, retain) NSString *distance;
@property(nonatomic, retain) NSString *locality;

@end
