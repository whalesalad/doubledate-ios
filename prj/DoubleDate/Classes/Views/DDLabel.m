//
//  DDLabel.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDLabel.h"

@implementation DDLabel

@synthesize inputView;
@synthesize inputAccessoryView;

- (void)dealloc
{
    [inputView release];
    [inputAccessoryView release];
    [super dealloc];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self becomeFirstResponder];
}

@end
