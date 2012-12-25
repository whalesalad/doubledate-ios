//
//  DDObjectsController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *DDObjectsControllerDidUpdateObjectNotification;

@interface DDObjectsController : NSObject
{
}

+ (void)updateObject:(NSObject*)object;
+ (void)updateObjects:(NSArray*)objects;

@end
