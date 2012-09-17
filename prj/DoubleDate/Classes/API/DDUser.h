//
//  DDUser.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAPIObject.h"

extern NSString *DDUserGenderMale;
extern NSString *DDUserGenderFemale;
extern NSString *DDUserInterestGuys;
extern NSString *DDUserInterestGirls;
extern NSString *DDUserInterestBoth;

@class DDPlacemark;

@interface DDUser : DDAPIObject
{
}

@property(nonatomic, retain) NSString *birthday;
@property(nonatomic, retain) NSString *lastName;
@property(nonatomic, retain) NSString *userId;
@property(nonatomic, retain) NSString *gender;
@property(nonatomic, retain) NSNumber *age;
@property(nonatomic, retain) NSString *photo;
@property(nonatomic, retain) NSString *firstName;
@property(nonatomic, retain) NSString *interestedIn;
@property(nonatomic, retain) NSNumber *single;

@property(nonatomic, retain) NSString *bio;

@property(nonatomic, retain) NSNumber *facebookId;

@property(nonatomic, retain) NSString *email;
@property(nonatomic, retain) NSString *password;

@property(nonatomic, retain) DDPlacemark *location;

@property(nonatomic, retain) NSArray *interests;

@end
