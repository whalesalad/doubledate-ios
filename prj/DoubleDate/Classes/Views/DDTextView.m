//
//  DDTextView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTextView.h"
#import "DDTools.h"

@implementation DDTextView

@synthesize backgroundImageView = backgroundImageView_;

- (void)initSelf
{
    //add background image view
    [backgroundImageView_ removeFromSuperview];
    [backgroundImageView_ release];
    backgroundImageView_ = [[UIImageView alloc] init];
    backgroundImageView_.backgroundColor = [UIColor clearColor];
    backgroundImageView_.userInteractionEnabled = NO;
    [self addSubview:backgroundImageView_];
    
    //add text view
    [textView_ removeFromSuperview];
    [textView_ release];
    textView_ = [[UITextView alloc] init];
    textView_.backgroundColor = [UIColor clearColor];
    DD_F_TEXT(textView_);
    [self addSubview:textView_];
    
    //add text field
    [textField_ removeFromSuperview];
    [textField_ release];
    textField_ = [[UITextField alloc] init];
    textField_.userInteractionEnabled = NO;
    textField_.font = textView_.font;
    textField_.backgroundColor = [UIColor clearColor];
    DD_F_TEXT(textField_);
    [self addSubview:textField_];
    
    //add notification handling
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:textView_];
}

- (void)updatePlaceholder
{
    textField_.placeholder = [textView_.text length]?nil:placeholder_;
}

- (void)textDidChange:(NSNotification*)notification
{
    if ([notification object] == textView_)
        [self updatePlaceholder];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initSelf];
        self.frame = self.frame;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self initSelf];
        self.frame = self.frame;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    textField_.frame = CGRectMake(8, 9, self.frame.size.width-10, self.frame.size.height-8);
    textView_.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    backgroundImageView_.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setFont:(UIFont *)font
{
    textView_.font = font;
    textField_.font = font;
}

- (UIFont*)font
{
    return textView_.font;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    if (placeholder != placeholder_)
    {
        [placeholder_ release];
        placeholder_ = [placeholder retain];
    }
    [self updatePlaceholder];
}

- (NSString*)placeholder
{
    return placeholder_;
}

- (void)setText:(NSString *)text
{
    [textView_ setText:text];
    [self updatePlaceholder];
}

- (NSString*)text
{
    return [textView_ text];
}

- (UITextView*)textView
{
    return textView_;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [backgroundImageView_ release];
    [textView_ release];
    [textField_ release];
    [placeholder_ release];
    [super dealloc];
}

@end
