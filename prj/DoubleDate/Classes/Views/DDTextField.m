//
//  DDTextField.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTextField.h"
#import "DDSearchBar.h"
#import "DDTools.h"

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

@implementation DDTextField

- (void)selfInit
{
    //set font
    self.font = [DDTools boldAvenirFontOfSize:14];
    
    //add reset button
    UIImage *clearImage = [UIImage imageNamed:@"search-clear-button.png"];
    UIButton *clearButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, clearImage.size.width, clearImage.size.height)] autorelease];
    [clearButton setImage:clearImage forState:UIControlStateNormal];
    [self setClearButtonMode:UITextFieldViewModeNever];
    [self setRightView:clearButton];
    [self setRightViewMode:UITextFieldViewModeNever];
    [clearButton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChange:) name:UITextFieldTextDidChangeNotification object:self];
}

- (void)updateClearButton
{
    self.rightViewMode = [self.text length]>0?UITextFieldViewModeAlways:UITextFieldViewModeNever;
}

- (void)didChange:(NSNotification*)notification
{
    [self updateClearButton];
}

- (void)clear
{
    [self becomeFirstResponder];
    self.text = nil;
    [self updateClearButton];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self updateClearButton];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self selfInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self selfInit];
    }
    return self;
}

@end
