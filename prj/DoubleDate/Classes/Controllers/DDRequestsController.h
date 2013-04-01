//
//  DDRequestsController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RKRequest;
@protocol RKRequestDelegate;

@interface DDRequestsController : NSObject
{
    NSMutableArray *requests_;
}

@property(nonatomic, assign) id<RKRequestDelegate> delegate;

@property(nonatomic, readonly) NSArray *requests;

+ (DDRequestsController*)sharedDummyController;
+ (DDRequestsController*)sharedMeController;

+ (void)setActiveRequestsCount:(NSInteger)count;
+ (NSInteger)activeRequestsCount;

- (void)startRequest:(RKRequest*)request;
- (void)stopAllRequests;

@end
