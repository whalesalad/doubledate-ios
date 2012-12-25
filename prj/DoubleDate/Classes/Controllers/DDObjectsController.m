//
//  DDObjectsController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDObjectsController.h"

NSString *DDObjectsControllerDidUpdateObjectNotification = @"DDObjectsControllerDidUpdateObjectNotification";

@implementation DDObjectsController

+ (void)updateObject:(NSObject*)object
{
    if ([object isKindOfClass:[NSArray class]])
    {
        for (NSObject *o in (NSArray*)object)
            [self updateObject:o];
    }
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:DDObjectsControllerDidUpdateObjectNotification object:object];
}

+ (void)updateObjects:(NSArray*)objects
{
    for (NSObject *object in objects)
        [self updateObject:object];
}

@end
