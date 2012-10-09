//
//  DDFriendship.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 08.10.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAPIObject.h"
#import "DDShortUser.h"

@interface DDFriendship : DDAPIObject

@property(nonatomic, retain) NSNumber *approved;
@property(nonatomic, retain) NSString *createdAt;
@property(nonatomic, retain) NSNumber *identifier;
@property(nonatomic, retain) NSString *uuid;
@property(nonatomic, retain) DDShortUser *meUser;
@property(nonatomic, retain) DDShortUser *friendUser;

@end
