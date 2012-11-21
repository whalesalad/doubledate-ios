//
//  DDWEImageView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDWEImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DDWEImageView

- (CGRect)displayAreaForPopover
{
    return [self.popoverDelegate displayAreaForPopoverFromView:self];
}

@end
