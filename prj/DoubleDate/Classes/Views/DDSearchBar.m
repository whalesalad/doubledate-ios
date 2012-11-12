//
//  DDSearchBar.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDSearchBar.h"
#import "DDTools.h"

@implementation DDSearchBar

- (UITextField*)textField
{
    for (UITextField *textField in [self subviews])
    {
        if ([textField isKindOfClass:[UITextField class]])
            return textField;
    }
    return nil;
}

- (void)initSelf
{
    //set text color
    [[self textField] setTextColor:[UIColor grayColor]];
    
    //set text font
    DD_F_TEXT([self textField]);
    
    //always enable search button
    [self textField].enablesReturnKeyAutomatically = NO;
    
    //set background image
    [self setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"search-background"]]];
    
    //set background image color
    [self setSearchFieldBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"search-input-background.png"]] forState:UIControlStateNormal];
    
    //set search icon
    [self setImage:[UIImage imageNamed:@"search-icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    //set search icon
    [self setImage:[UIImage imageNamed:@"search-clear-button.png"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self initSelf];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
