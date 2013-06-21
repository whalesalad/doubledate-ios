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

//#if DEBUG
//#define API_URL @"http://staging.dbld8.com"
//#define SERVER_URL @"http://staging.dbld8.com"
//#else
//#define API_URL @"https://api.dbld8.com"
//#define SERVER_URL @"http://dbld8.com"
//#endif

#define API_URL @"http://staging.dbld8.com"
#define SERVER_URL @"http://staging.dbld8.com"

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
