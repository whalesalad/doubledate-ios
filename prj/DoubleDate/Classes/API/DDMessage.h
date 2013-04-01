//
//  DDMessage.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
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
