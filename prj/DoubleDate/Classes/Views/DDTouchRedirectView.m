//
//  DDTouchRedirectView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 12/24/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTouchRedirectView.h"

@implementation DDTouchRedirectView

@synthesize redirectView;

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return [self pointInside:point withEvent:event]?self.redirectView:nil;
}

- (void)dealloc
{
    [redirectView release];
    [super dealloc];
}

@end
