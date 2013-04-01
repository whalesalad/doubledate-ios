//
//  DDNotification.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAPIObject.h"

@class DDDialog;

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
@property(nonatomic, retain) DDDialog *dialog;

@end
