//
//  DDTools
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTools.h"
#import <SBJson/SBJson.h>

//#define SERVER_URL @"http://dbld8.herokuapp.com"
#define SERVER_URL @"https://api.dbld8.com"

@implementation DDTools

+ (NSString*)apiUrlPath
{
    return SERVER_URL;
}

+ (NSString*)authUrlPath
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

@end
