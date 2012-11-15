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

- (UIButton*)button
{
    for (UIButton *button in [self subviews])
    {
        if ([button isKindOfClass:[UIButton class]])
            return button;
    }
    return nil;
}

- (void)customizeTextField
{
    //customize field
    DD_F_TEXT([self textField]);
}

- (void)customizeButton
{
    //customize field
    DD_F_BUTTON([self button]);
    
    //set cancel button
    [[self button] setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"search-cancel-button.png"]] forState:UIControlStateNormal];
    [[self button] setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"search-cancel-button.png"]] forState:UIControlStateHighlighted];
    
    //change button frame
    if (self.showsCancelButton)
        [[self button] setFrame:CGRectMake(255, 7, 55, 30)];
}

- (void)initSelf
{
    //set background image
    [self setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"search-background"]]];
    
    //set background image color
    [self setSearchFieldBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"search-input-background.png"]] forState:UIControlStateNormal];
    
    //set search icon
    [self setImage:[UIImage imageNamed:@"search-icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    //set search icon
    [self setImage:[UIImage imageNamed:@"search-clear-button.png"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    
    //customize elements
    [self customizeTextField];
    
    //customize button
    [self customizeButton];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self initSelf];
    }
    return self;
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton
{
    [super setShowsCancelButton:showsCancelButton];
    [self customizeButton];
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated
{
    [super setShowsCancelButton:showsCancelButton animated:animated];
    [self customizeButton];
}

- (void)dealloc
{
    [super dealloc];
}

@end
