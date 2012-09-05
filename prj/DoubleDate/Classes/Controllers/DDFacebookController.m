//
//  DDFacebookController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDFacebookController.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation DDFacebookController

static DDFacebookController *_sharedInstance = nil;

+ (DDFacebookController*)sharedController
{
    if (!_sharedInstance)
        _sharedInstance = [[DDFacebookController alloc] init];
    return _sharedInstance;
}

- (void)login
{
}

@end
