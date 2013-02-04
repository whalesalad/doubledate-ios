//
//  DDObjectsController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDObjectsController.h"
#import "DDAPIObject.h"

NSString *DDObjectsControllerDidUpdateObjectNotification = @"DDObjectsControllerDidUpdateObjectNotification";
NSString *DDObjectsControllerDidUpdateObjectRestKitMethodUserInfoKey = @"DDObjectsControllerDidUpdateObjectRestKitMethodUserInfoKey";

@interface DDObjectsController ()

+ (void)cacheObject:(DDAPIObject*)object withMethod:(RKRequestMethod)method forPath:(NSString*)path;
+ (void)cacheObjects:(NSArray*)objects withMethod:(RKRequestMethod)method forPath:(NSString*)path;

@end

@implementation DDObjectsController

+ (void)updateObject:(DDAPIObject*)object withMethod:(RKRequestMethod)method cachePath:(NSString*)cachePath
{
    if ([object isKindOfClass:[NSArray class]])
    {
        for (DDAPIObject *o in (NSArray*)object)
            [self updateObject:o withMethod:method cachePath:cachePath];
    }
    else
    {
        //check if we need to cache
        if (cachePath)
            [self cacheObject:object withMethod:method forPath:cachePath];
        
        //inform about update
        [[NSNotificationCenter defaultCenter] postNotificationName:DDObjectsControllerDidUpdateObjectNotification object:object userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:method] forKey:DDObjectsControllerDidUpdateObjectRestKitMethodUserInfoKey]];
    }
}

+ (void)updateObjects:(NSArray*)objects withMethod:(RKRequestMethod)method cachePath:(NSString*)cachePath
{
    //update objects without caching
    for (DDAPIObject *object in objects)
        [self updateObject:object withMethod:method cachePath:nil];

    //cache all objects
    if (cachePath)
        [self cacheObjects:objects withMethod:method forPath:cachePath];
}

+ (NSString*)fullKeyForKey:(NSString*)key ofClass:(Class)objectsClass
{
    return [NSString stringWithFormat:@"%@%@", key, NSStringFromClass(objectsClass)];
}

+ (NSArray*)objectsForKey:(NSString*)key ofClass:(Class)objectsClass
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:[self fullKeyForKey:key ofClass:objectsClass]];
}

+ (void)setObjects:(NSArray*)objects ofClass:(Class)objectsClass forKey:(NSString*)key
{
    NSString *fullKey = [self fullKeyForKey:key ofClass:objectsClass];
    if ([objects count])
        [[NSUserDefaults standardUserDefaults] setObject:objects forKey:fullKey];
    else
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:fullKey];
}

+ (void)cacheObject:(DDAPIObject*)object withMethod:(RKRequestMethod)method forPath:(NSString*)path
{
    if (object)
        [self cacheObjects:[NSArray arrayWithObject:object] withMethod:method forPath:path];
}

+ (void)cacheObjects:(NSArray*)objects withMethod:(RKRequestMethod)method forPath:(NSString*)path
{
    //check for dummy
    if ([objects count] == 0)
        return;
    
    //extract previous objects
    NSMutableArray *objectsToReplace = [NSMutableArray array];
    Class objectClass = [[objects lastObject] class];
    NSArray *cachedDictionaries = [self objectsForKey:path ofClass:objectClass];
    
    //check object
    for (DDAPIObject *object in objects)
    {
        //set save flag
        BOOL needToAddObject = method != RKRequestMethodDELETE;
        
        //check each cached object
        for (NSDictionary *dictionary in cachedDictionaries)
        {
            //check the same object from cache
            if ([[dictionary objectForKey:@"uniqueKey"] isEqualToString:[object uniqueKey]])
            {
                if (method == RKRequestMethodGET || method == RKRequestMethodPUT || method == RKRequestMethodPOST)
                {
                    needToAddObject = NO;
                    [objectsToReplace addObject:[object dictionaryRepresentation]];
                }
            }
            else
                [objectsToReplace addObject:dictionary];
        }
        
        //check if we need to add the object
        if (needToAddObject)
            [objectsToReplace addObject:[object dictionaryRepresentation]];
    }
    
    //save new objects to cache
    [self setObjects:objectsToReplace ofClass:objectClass forKey:path];
}

+ (NSArray*)cachedObjectsOfClass:(Class)objectsClass forPath:(NSString*)path
{
    NSMutableArray *ret = [NSMutableArray array];
    NSArray *cachedDictionaries = [self objectsForKey:path ofClass:objectsClass];
    for (NSDictionary *dictionary in cachedDictionaries)
    {
        if ([objectsClass isSubclassOfClass:[DDAPIObject class]])
        {
            DDAPIObject *o = [[[objectsClass alloc] initWithDictionary:dictionary] autorelease];
            [ret addObject:o];
        }
    }
    return ret;
}

@end
