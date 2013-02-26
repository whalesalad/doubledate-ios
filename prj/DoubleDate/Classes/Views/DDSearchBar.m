//
//  DDSearchBar.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDSearchBar.h"
#import "DDTools.h"
#import <QuartzCore/QuartzCore.h>

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
    // self.textField.textColor = [UIColor colorWithRed:204 green:204 blue:204 alpha:1];
    DD_F_PLACEHOLDER(self.textField);
}

- (void)customizeButton
{
    //customize field
    [[self button] setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    //set cancel button
    [[self button] setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"search-cancel-button.png"]] forState:UIControlStateNormal];
    [[self button] setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"search-cancel-button.png"]] forState:UIControlStateHighlighted];
    
    //change button frame
    if (self.showsCancelButton)
        [[self button] setFrame:CGRectMake(255, 7, 60, 24)];
}

- (void)initSelf
{
    //set background image
    [self setBackgroundImage:[UIImage imageNamed:@"search-background"]];
    
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
    
    //customize self
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 0.7f;
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
