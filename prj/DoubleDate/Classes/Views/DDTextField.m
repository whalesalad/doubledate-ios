//
//  DDTextField.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTextField.h"
#import "DDSearchBar.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation UITextField (Placeholder)

- (UIColor*)standardColor
{
    return [UIColor grayColor];
}

- (UIColor*)searchBarColor
{
    return [UIColor lightGrayColor];
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    if ([self.superview isKindOfClass:[DDSearchBar class]])
        [[self searchBarColor] setFill];
    else
        [[self standardColor] setFill];
    [[self placeholder] drawInRect:rect withFont:[self font]];
}

@end

#pragma clang diagnostic pop
