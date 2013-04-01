//
//  NSObject+DD.m
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "NSObject+DD.h"

@implementation NSObject (DD)

- (void)setFontOfName:(NSString*)fontName fontSize:(CGFloat)fontSize textColor:(UIColor*)textColor shadowOffset:(CGSize)shadowOffset shadowColor:(UIColor*)shadowColor
{
    if ([self respondsToSelector:@selector(setFont:)])
        [(id)self setFont:[UIFont fontWithName:fontName size:fontSize]];
    if ([self respondsToSelector:@selector(setTextColor:)])
        [(id)self setTextColor:textColor];
    if ([self respondsToSelector:@selector(setShadowColor:)])
        [(id)self setShadowColor:shadowColor];
    if ([self respondsToSelector:@selector(setShadowOffset:)])
        [(id)self setShadowOffset:shadowOffset];
    if ([self isKindOfClass:[UIButton class]])
    {
        [[(UIButton*)self titleLabel] setFontOfName:fontName fontSize:fontSize textColor:textColor shadowOffset:shadowOffset shadowColor:shadowColor];
    }
}

@end
