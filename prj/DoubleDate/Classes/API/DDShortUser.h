//
//  DDShortUser.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 09.10.12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAPIObject.h"
#import "DDImage.h"

@interface DDShortUser : DDAPIObject

@property(nonatomic, retain) NSString *gender;
@property(nonatomic, retain) NSNumber *identifier;
@property(nonatomic, retain) NSNumber *facebookId;
@property(nonatomic, retain) NSString *fullName;
@property(nonatomic, retain) NSString *firstName;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSNumber *age;
@property(nonatomic, retain) NSString *location;
@property(nonatomic, retain) DDImage *photo;
@property(nonatomic, retain) NSNumber *approved;
@property(nonatomic, retain) NSNumber *ghost;


- (NSString*)displayName;
- (BOOL)isGhost;

+ (NSString*)nameForShortUser:(DDShortUser*)user;

@end

@interface DDShortGhost : DDShortUser
@end
