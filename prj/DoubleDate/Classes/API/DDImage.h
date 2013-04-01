//
//  DDImage.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDAPIObject.h"

@interface DDImage : DDAPIObject
{
}

@property(nonatomic, retain) NSString *thumbUrl;
@property(nonatomic, retain) NSString *smallUrl;
@property(nonatomic, retain) NSString *mediumUrl;
@property(nonatomic, retain) NSString *largeUrl;
@property(nonatomic, retain) UIImage *uploadImage;

@end
