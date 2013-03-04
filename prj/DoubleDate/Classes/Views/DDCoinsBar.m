//
//  DDCoinsBar.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDCoinsBar.h"
#import "DDTools.h"

@interface DDCoinsBar()

@property(nonatomic, retain) IBOutlet UIButton *buttonMoreCoins;
@property(nonatomic, retain) IBOutlet UIView *labelCoinsContainer;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewCoins;
@property(nonatomic, retain) IBOutlet UILabel *labelCoins;

@end

@implementation DDCoinsBar

@synthesize buttonMoreCoins;
@synthesize labelCoinsContainer;
@synthesize imageViewCoins;
@synthesize labelCoins;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //update more coins button
    [self.buttonMoreCoins setBackgroundImage:[DDTools resizableImageFromImage:[self.buttonMoreCoins backgroundImageForState:UIControlStateNormal]] forState:UIControlStateNormal];
}

- (void)layoutSubviews
{
    //save distance between label and button
    CGFloat gap = (self.labelCoins.frame.origin.x - self.imageViewCoins.frame.origin.x - self.imageViewCoins.frame.size.width);
    
    //move label coins
    CGSize newLabelSize = CGSizeMake([self.labelCoins sizeThatFits:self.labelCoins.bounds.size].width, self.labelCoins.frame.size.height);
    
    //align button
    CGSize newButtonSize = CGSizeMake([self.buttonMoreCoins sizeThatFits:self.buttonMoreCoins.bounds.size].width, self.buttonMoreCoins.frame.size.height);
    
    //update label container
//    self.labelCoinsContainer.frame = CGRectMake(0, self.labelCoinsContainer.frame.origin.y, self.frame.size.width - newButtonSize.width, self.labelCoinsContainer.frame.size.height);
    
    //update button
    self.buttonMoreCoins.frame = CGRectMake(self.buttonMoreCoins.frame.origin.x - newButtonSize.width + self.buttonMoreCoins.frame.size.width, self.buttonMoreCoins.frame.origin.y, newButtonSize.width, self.buttonMoreCoins.frame.size.height);
    
    //update center of the label
    self.labelCoins.frame = CGRectMake(0, self.labelCoins.frame.origin.y, newLabelSize.width, self.labelCoins.frame.size.height);
    self.labelCoins.center = CGPointMake(self.labelCoinsContainer.frame.size.width / 2 + (gap + self.imageViewCoins.frame.size.width) / 2, self.labelCoins.center.y);
    
    //update center of image view coins
    self.imageViewCoins.center = CGPointMake(self.labelCoins.frame.origin.x - gap - self.imageViewCoins.frame.size.width / 2, self.imageViewCoins.center.y);
}

- (void)setValue:(NSInteger)value
{
    self.labelCoins.text = [NSString stringWithFormat:@"%d", value];
    [self setNeedsLayout];
}

- (void)setButtonTitle:(NSString*)title
{
    [self.buttonMoreCoins setTitle:title forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.buttonMoreCoins addTarget:target action:action forControlEvents:controlEvents];
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.buttonMoreCoins removeTarget:target action:action forControlEvents:controlEvents];
}

- (NSSet *)allTargets
{
    return [self.buttonMoreCoins allTargets];
}

- (UIControlEvents)allControlEvents
{
    return [self.buttonMoreCoins allControlEvents];
}
- (NSArray *)actionsForTarget:(id)target forControlEvent:(UIControlEvents)controlEvent
{
    return [self.buttonMoreCoins actionsForTarget:target forControlEvent:controlEvent];
}

- (void)dealloc
{
    [buttonMoreCoins release];
    [labelCoinsContainer release];
    [imageViewCoins release];
    [labelCoins release];
    [super dealloc];
}

@end
