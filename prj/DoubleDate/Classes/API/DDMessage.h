//
//  DDMessage.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAPIObject.h"

@interface DDMessage : DDAPIObject
{
}

@property(nonatomic, retain) NSString *createdAt;
@property(nonatomic, retain) NSString *createdAtAgo;
@property(nonatomic, retain) NSNumber *identifier;
@property(nonatomic, retain) NSString *message;
@property(nonatomic, retain) NSNumber *userId;
@property(nonatomic, retain) NSString *firstName;

@end
