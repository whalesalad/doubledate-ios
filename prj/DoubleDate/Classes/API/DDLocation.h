//
//  DDLocation.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/11/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAPIObject.h"

extern NSString *DDLocationTypeCity;
extern NSString *DDLocationTypeVenue;

@interface DDLocation : DDAPIObject

@property(nonatomic, retain) NSNumber *activitiesCount;
@property(nonatomic, retain) NSString *address;
@property(nonatomic, retain) NSNumber *identifier;
@property(nonatomic, retain) NSNumber *latitude;
@property(nonatomic, retain) NSString *locality;
@property(nonatomic, retain) NSNumber *longitude;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *state;
@property(nonatomic, retain) NSNumber *usersCount;
@property(nonatomic, retain) NSString *venue;
@property(nonatomic, retain) NSString *country;
@property(nonatomic, retain) NSString *type;
@property(nonatomic, retain) NSString *locationName;

@end
