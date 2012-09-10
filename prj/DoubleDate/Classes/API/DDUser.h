//
//  DDUser.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAPIObject.h"

@interface DDUser : DDAPIObject
{
}

@property(nonatomic, retain) NSString *birthday;
@property(nonatomic, retain) NSString *lastName;
@property(nonatomic, retain) NSString *userId;
@property(nonatomic, retain) NSString *gender;
@property(nonatomic, retain) NSString *age;
@property(nonatomic, retain) NSString *photo;
@property(nonatomic, retain) NSString *firstName;
@property(nonatomic, retain) NSString *interestedIn;
@property(nonatomic, retain) NSString *single;

@property(nonatomic, retain) NSString *bio;

@property(nonatomic, retain) NSString *interests;

@property(nonatomic, retain) NSString *facebookId;

@property(nonatomic, retain) NSString *email;
@property(nonatomic, retain) NSString *password;

@end
