//
//  DDDialog.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAPIObject.h"

@class DDPlacemark;
@class DDImage;

@interface DDDialog : DDAPIObject
{
}

@property(nonatomic, retain) NSString *slug;
@property(nonatomic, retain) NSNumber *userId;
@property(nonatomic, retain) NSNumber *coins;
@property(nonatomic, retain) NSString *upperText;
@property(nonatomic, retain) NSString *description;
@property(nonatomic, retain) NSString *confirmText;
@property(nonatomic, retain) NSString *confirmUrl;
@property(nonatomic, retain) NSString *dismissText;

@end
