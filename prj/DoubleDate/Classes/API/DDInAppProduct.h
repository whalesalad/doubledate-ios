//
//  DDInAppProduct.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAPIObject.h"

@interface DDInAppProduct : DDAPIObject
{
}

@property(nonatomic, retain) NSString *identifier;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSNumber *coins;
@property(nonatomic, retain) NSNumber *popular;

@end
