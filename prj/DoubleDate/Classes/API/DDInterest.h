//
//  DDInterest.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAPIObject.h"

@interface DDInterest : DDAPIObject
{
}

@property(nonatomic, retain) NSNumber *identifier;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSNumber *facebookId;
@property(nonatomic, retain) NSNumber *matched;

@end
