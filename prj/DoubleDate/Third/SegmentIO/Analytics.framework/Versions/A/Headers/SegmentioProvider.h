// SegmentioProvider.h
// Copyright 2013 Segment.io

#import <Foundation/Foundation.h>
#import "Provider.h"


@interface SegmentioProvider : Provider

@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) BOOL enabled;
@property(nonatomic, assign) BOOL valid;
@property(nonatomic, assign) BOOL initialized;
@property(nonatomic, strong) NSDictionary *settings;

+ (instancetype)withSecret:(NSString *)secret;
- (id)initWithSecret:(NSString *)secret;

@end
