//
//  DDNotification.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAPIObject.h"

@interface DDNotification : DDAPIObject
{
}

@property(nonatomic, retain) NSNumber *identifier;
@property(nonatomic, retain) NSString *uuid;
@property(nonatomic, retain) NSString *notification;
@property(nonatomic, retain) NSNumber *push;
@property(nonatomic, retain) NSNumber *unread;
@property(nonatomic, retain) NSString *callbackUrl;
@property(nonatomic, retain) NSArray *photos;
@property(nonatomic, retain) NSString *createdAt;
@property(nonatomic, retain) NSString *createdAtAgo;

@end
