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

- (void)initSelf
{
    //add text view
    [textView_ removeFromSuperview];
    [textView_ release];
    textView_ = [[UITextView alloc] init];
    textView_.backgroundColor = [UIColor clearColor];
    DD_F_TEXT(textView_);
    [self addSubview:textView_];
    
    //add text field
    [label_ removeFromSuperview];
    [label_ release];
    label_ = [[UILabel alloc] init];
    label_.userInteractionEnabled = NO;
    label_.font = textView_.font;
    label_.backgroundColor = [UIColor clearColor];
    label_.contentMode = UIViewContentModeTopLeft;
    DD_F_PLACEHOLDER(label_);
    [self addSubview:label_];
    
    //add notification handling
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:textView_];
}

- (void)updatePlaceholder
{
    label_.text = [textView_.text length]?nil:placeholder_;
    CGSize newLabelSize = [placeholder_ sizeWithFont:label_.font constrainedToSize:CGSizeMake(label_.frame.size.width, self.frame.size.height) lineBreakMode:NSLineBreakByWordWrapping];
    label_.numberOfLines = newLabelSize.height / label_.font.pointSize;
    label_.frame = CGRectMake(label_.frame.origin.x, label_.frame.origin.y, label_.frame.size.width, newLabelSize.height);
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
    label_.frame = CGRectMake(8, 9, self.frame.size.width-10, 0);
    [self updatePlaceholder];
    label_.frame = CGRectMake(label_.frame.origin.x, label_.frame.origin.y, label_.frame.size.width, [label_ sizeThatFits:label_.bounds.size].height);
    textView_.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setFont:(UIFont *)font
{
    textView_.font = font;
    label_.font = font;
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
    [textView_ release];
    [label_ release];
    [placeholder_ release];
    [super dealloc];
}

@end
