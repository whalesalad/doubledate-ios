//
//  DDRequestsController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
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
