//
//  DDObjectsController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@class DDAPIObject;

extern NSString *DDObjectsControllerDidUpdateObjectNotification;
extern NSString *DDObjectsControllerDidUpdateObjectRestKitMethodUserInfoKey;

@interface DDObjectsController : NSObject
{
}

+ (void)updateObject:(DDAPIObject*)object withMethod:(RKRequestMethod)method cachePath:(NSString*)cachePath;
+ (void)updateObjects:(NSArray*)objects withMethod:(RKRequestMethod)method cachePath:(NSString*)cachePath;

+ (NSArray*)cachedObjectsOfClass:(Class)objectsClass forPath:(NSString*)path;

@end
