//
//  DDUser.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAPIObject.h"

extern NSString *DDUserGenderMale;
extern NSString *DDUserGenderFemale;
extern NSString *DDUserInterestGuys;
extern NSString *DDUserInterestGirls;
extern NSString *DDUserInterestBoth;

@class DDPlacemark;
@class DDImage;

@interface DDUser : DDAPIObject
{
}

@property(nonatomic, retain) NSString *birthday;
@property(nonatomic, retain) NSString *lastName;
@property(nonatomic, retain) NSNumber *userId;
@property(nonatomic, retain) NSString *gender;
@property(nonatomic, retain) NSNumber *age;
@property(nonatomic, retain) NSString *firstName;
@property(nonatomic, retain) NSString *interestedIn;
@property(nonatomic, retain) NSNumber *single;

@property(nonatomic, retain) NSString *bio;

@property(nonatomic, retain) NSNumber *facebookId;
@property(nonatomic, retain) NSString *facebookAccessToken;

@property(nonatomic, retain) NSString *email;
@property(nonatomic, retain) NSString *password;

@property(nonatomic, retain) DDPlacemark *location;

@property(nonatomic, retain) DDImage *photo;

@property(nonatomic, retain) NSArray *interests;

@property(nonatomic, retain) NSString *uuid;

@property(nonatomic, retain) NSString *inviteSlug;
@property(nonatomic, retain) NSString *invitePath;

@property(nonatomic, retain) NSNumber *totalCoins;
@property(nonatomic, retain) NSNumber *totalKarma;

@property(nonatomic, retain) NSNumber *unreadNotificationsCount;
@property(nonatomic, retain) NSNumber *unreadMessagesCount;
@property(nonatomic, retain) NSNumber *pendingWingsCount;

@end
