//
//  DDTools
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTools.h"
#import "SBJson.h"
#import <QuartzCore/QuartzCore.h>
#import <RestKit/RKISO8601DateFormatter.h>

//#define API_URL @"http://localhost:3000"
#define API_URL @"http://api-2.dbld8.com"
#define SERVER_URL @"http://dbld8.com"

@implementation DDTools

+ (NSString*)apiUrlPath
{
    return API_URL;
}

+ (NSString*)authUrlPath
{
    return API_URL;
}

+ (NSString*)serverUrlPath
{
    return SERVER_URL;
}

+ (NSString*)errorMessageFromResponseData:(NSData*)data
{
    NSString *ret = nil;
    
    //save response object
    NSDictionary *responseObject = [[[[SBJsonParser alloc] init] autorelease] objectWithData:data];
    
    //extract message
    if ([responseObject isKindOfClass:[NSDictionary class]])
    {
        if ([[responseObject objectForKey:@"error"] isKindOfClass:[NSString class]])
            ret = [responseObject objectForKey:@"error"];
    }
    
    return ret;
}

+ (NSString*)codeMessageFromResponseData:(NSData*)data
{
    NSString *ret = nil;
    
    //save response object
    NSDictionary *responseObject = [[[[SBJsonParser alloc] init] autorelease] objectWithData:data];
    
    //extract message
    if ([responseObject isKindOfClass:[NSDictionary class]])
    {
        if ([[responseObject objectForKey:@"code"] isKindOfClass:[NSString class]])
            ret = [responseObject objectForKey:@"code"];
    }
    
    return ret;
}

+ (UIImage*)imageFromView:(UIView*)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIImage imageWithCGImage:image.CGImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
}

+ (UIImage*)resizableImageFromImage:(UIImage*)image
{
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2, image.size.width/2, image.size.height/2, image.size.width/2)];
}

+ (UIImage*)scaledImageFromImage:(UIImage*)image ofSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ret;
}

+ (UIImage*)clearImage
{
    return [self clearImageOfSize:CGSizeMake(1, 1)];
}

+ (UIImage*)clearImageOfSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGRect fillRect = CGRectMake(0, 0, size.width, size.height);
    CGContextSetFillColorWithColor(currentContext, [UIColor clearColor].CGColor);
    CGContextFillRect(currentContext, fillRect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (BOOL)isiPhone5Device
{
    if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)] && [[UIScreen mainScreen] bounds].size.height * [UIScreen mainScreen].scale == 1136)
        return YES;
    return NO;
}

+ (NSDate*)dateFromString:(NSString*)string
{
    return [[[[RKISO8601DateFormatter alloc] init] autorelease] dateFromString:string];
}

@end
