//
//  DDObjectsController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

extern NSString *DDObjectsControllerDidUpdateObjectNotification;
extern NSString *DDObjectsControllerDidUpdateObjectRestKitMethodUserInfoKey;

@interface DDObjectsController : NSObject
{
}

+ (void)updateObject:(NSObject*)object withMethod:(RKRequestMethod)method;
+ (void)updateObjects:(NSArray*)objects withMethod:(RKRequestMethod)method;

@end
