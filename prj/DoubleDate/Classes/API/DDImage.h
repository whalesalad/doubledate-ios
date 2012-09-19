//
//  DDImage.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDAPIObject.h"

@interface DDImage : DDAPIObject
{
}

@property(nonatomic, retain) NSString *downloadUrl;
@property(nonatomic, retain) UIImage *uploadImage;

@end
