//
//  DDObjectsController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDObjectsController.h"

NSString *DDObjectsControllerDidUpdateObjectNotification = @"DDObjectsControllerDidUpdateObjectNotification";
NSString *DDObjectsControllerDidUpdateObjectRestKitMethodUserInfoKey = @"DDObjectsControllerDidUpdateObjectRestKitMethodUserInfoKey";

@implementation DDObjectsController

+ (void)updateObject:(NSObject*)object withMethod:(RKRequestMethod)method
{
    if ([object isKindOfClass:[NSArray class]])
    {
        for (NSObject *o in (NSArray*)object)
            [self updateObject:o withMethod:method];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:DDObjectsControllerDidUpdateObjectNotification object:object userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:method] forKey:DDObjectsControllerDidUpdateObjectRestKitMethodUserInfoKey]];
    }
}

+ (void)updateObjects:(NSArray*)objects withMethod:(RKRequestMethod)method
{
    for (NSObject *object in objects)
        [self updateObject:object withMethod:method];
}

@end
