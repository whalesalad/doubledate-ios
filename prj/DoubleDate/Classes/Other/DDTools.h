//
//  DDTools.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    DDErrorTypeNone,
    DDErrorTypeCancelled,
    DDErrorTypeTimeout,
    DDErrorTypeOther
} DDErrorType;

extern NSString *DDErrorDomain;

@interface DDTools : NSObject
{
}

+ (NSString*)serverUrlPath;
+ (NSString*)apiUrlPath;
+ (NSString*)authUrlPath;

+ (NSString*)errorMessageFromResponseData:(NSData*)data;
+ (NSString*)codeMessageFromResponseData:(NSData*)data;

+ (UIImage*)imageFromView:(UIView*)view;

+ (UIImage*)resizableImageFromImage:(UIImage*)image;

+ (UIImage*)scaledImageFromImage:(UIImage*)image ofSize:(CGSize)size;

+ (UIImage*)cutImageFromImage:(UIImage*)image withRect:(CGRect)rect;

+ (UIImage*)clearImage;
+ (UIImage*)clearImageOfSize:(CGSize)size;

+ (BOOL)isiPhone5Device;

+ (NSDate*)dateFromString:(NSString*)string;
+ (NSString*)stringFromDate:(NSDate*)date;

@end
