//
//  DDTools
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTools.h"
#import "SBJson.h"
#import <QuartzCore/QuartzCore.h>
#import <RestKit/RKISO8601DateFormatter.h>
#import "UIImage+StackBlur.h"

#if DEBUG
#define API_URL @"http://staging.dbld8.com"
#define SERVER_URL @"http://staging.dbld8.com"
#else
#define API_URL @"https://api.dbld8.com"
#define SERVER_URL @"http://dbld8.com"
#endif

//#define API_URL @"http://localhost:3000"

NSString *DDErrorDomain = @"DDErrorDomain";

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

+ (UIImage*)blurFromImage:(UIImage*)image
{
#warning The commented code uses the native CIGaussianBlur and looks good but performs badly
//    CIContext *context = [CIContext contextWithOptions:nil];
//
//    CIImage *imageToBlur = [CIImage imageWithCGImage:image.CGImage];
//    
//    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
//    [gaussianBlurFilter setDefaults];
//    [gaussianBlurFilter setValue:imageToBlur forKey:@"inputImage"];
//    [gaussianBlurFilter setValue:[NSNumber numberWithFloat:10.0f] forKey:@"inputRadius"];
//
//    CIImage *blurredImage = [gaussianBlurFilter outputImage];
//    
//    CGImageRef resultImage = [context createCGImage:blurredImage fromRect:[imageToBlur extent]];
//    
//    UIImage *output = [UIImage imageWithCGImage:resultImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
    
//    return output;
#warning the stackBlur stuff looks the same and happens very quickly! =)
    UIImage *blurredImage = [UIImage imageWithCGImage:[[image stackBlur:10.0f] CGImage] scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
    return blurredImage;
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

+ (UIImage*)cutImageFromImage:(UIImage*)image withRect:(CGRect)rect
{
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [image drawInRect:CGRectMake(-rect.origin.x, -rect.origin.y, image.size.width, image.size.height)];
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

+ (NSString*)stringFromDate:(NSDate*)date
{
    NSDateFormatter *dateFormatterTo = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatterTo setDateFormat:@"d MMM yyyy, hh:mm"];
    return [dateFormatterTo stringFromDate:date];
}

+ (void)styleDualUserView:(UIView*)view
{
    view.backgroundColor = [UIColor colorWithWhite:0.110f alpha:1.0f];
    view.layer.shadowColor = [UIColor whiteColor].CGColor;
    view.layer.shadowOpacity = 0.05f;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowRadius = 0;
    
    CAGradientLayer *topViewGradient = [CAGradientLayer layer];
    topViewGradient.frame = view.bounds;
    topViewGradient.colors = [NSArray arrayWithObjects:
                              (id)[[UIColor colorWithWhite:0 alpha:0.5f] CGColor],
                              (id)[[UIColor clearColor] CGColor], nil];
    
    [view.layer insertSublayer:topViewGradient atIndex:0];
    
    CALayer *topViewInnerStroke = [CALayer layer];
    CGRect topViewInnerStrokeFrame = view.bounds;
    topViewInnerStrokeFrame.origin.y = topViewInnerStrokeFrame.size.height - 1;
    topViewInnerStrokeFrame.size.height = 1.0f;
    topViewInnerStroke.frame = topViewInnerStrokeFrame;
    topViewInnerStroke.backgroundColor = [UIColor colorWithWhite:0.09f alpha:1.0f].CGColor;
    
    [view.layer insertSublayer:topViewInnerStroke atIndex:1];
}

@end
