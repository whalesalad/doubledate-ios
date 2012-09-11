//
//  DDUserLocation.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAPIObject.h"

@interface DDUserLocation : DDAPIObject

@property(nonatomic, retain) NSString *locationId;
@property(nonatomic, retain) NSString *facebookId;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *latitude;
@property(nonatomic, retain) NSString *longitude;

@end
