//
//  DDTools.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    DDErrorTypeNone,
    DDErrorTypeCancelled,
    DDErrorTypeTimeout,
    DDErrorTypeOther
} DDErrorType;

@interface DDTools : NSObject
{
}

+ (NSString*)serverUrlPath;
+ (NSString*)apiUrlPath;
+ (NSString*)authUrlPath;

+ (NSString*)errorMessageFromResponseData:(NSData*)data;
+ (NSString*)codeMessageFromResponseData:(NSData*)data;

+ (UIImage*)imageFromView:(UIView*)view;

@end
