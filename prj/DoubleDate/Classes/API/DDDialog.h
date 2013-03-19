//
//  DDDialog.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
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
