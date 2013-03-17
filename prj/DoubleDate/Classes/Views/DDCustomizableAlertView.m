//
//  DDCustomizableAlertView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDCustomizableAlertView.h"
#import <QuartzCore/QuartzCore.h>

@interface DDCustomizableAlertView ()

@property(nonatomic, retain) IBOutlet UIView *viewCustomArea;
@property(nonatomic, retain) IBOutlet UILabel *labelMessage;
@property(nonatomic, retain) IBOutlet UIView *viewButtonsArea;
@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
@property(nonatomic, retain) IBOutlet UILabel *labelCoins;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewCoins;

@end

@implementation DDCustomizableAlertView
{
    DDCustomizableAlertView *core_;
}

@synthesize delegate;

@synthesize message;
@synthesize title;

@synthesize coins;

@synthesize viewCustomArea;
@synthesize labelMessage;
@synthesize viewButtonsArea;
@synthesize labelTitle;
@synthesize labelCoins;
@synthesize imageViewCoins;

- (void)show
{
    //make super
    [super show];
    
    //add core
    core_ = [[[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DDCustomizableAlertView class]) owner:self options:nil] objectAtIndex:0] retain];
    core_.center = self.bounceView.center;
    [self.bounceView addSubview:core_];
    
    //offset
    CGFloat offset = 0;
    
    //save initial layout
    CGPoint coreCenter = core_.center;
    CGFloat customAreaSizeBefore = core_.viewCustomArea.frame.size.height;
    CGFloat messageLabelSizeBefore = core_.labelMessage.frame.size.height;
    CGFloat buttonsAreaSizeBefore = core_.viewButtonsArea.frame.size.height;
    
    //set title
    core_.labelTitle.text = self.title;
    
    //set coins
    core_.labelCoins.text = [NSString stringWithFormat:@"%d", self.coins];
    
    //increase the size of custom area
    core_.viewCustomArea.frame = CGRectMake(core_.viewCustomArea.frame.origin.x, core_.viewCustomArea.frame.origin.y, core_.viewCustomArea.frame.size.width, [self.delegate heightForCustomAreaOfAlert:self]);
    
    //change offset
    offset += core_.viewCustomArea.frame.size.height - customAreaSizeBefore;
    
    //apply label text
    core_.labelMessage.text = self.message;
    
    //update label size according to content
    CGSize newLabelSize = [self.message sizeWithFont:core_.labelMessage.font constrainedToSize:CGSizeMake(core_.labelMessage.frame.size.width, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        
    //update the number of label lines
    core_.labelMessage.numberOfLines = newLabelSize.height / core_.labelMessage.font.pointSize;
    
    //move label
    core_.labelMessage.frame = CGRectMake(core_.labelMessage.frame.origin.x, core_.labelMessage.frame.origin.y + offset, core_.labelMessage.frame.size.width, newLabelSize.height);
    
    //change offset
    offset += core_.labelMessage.frame.size.height - messageLabelSizeBefore;
    
    //move buttons area
    core_.viewButtonsArea.frame = CGRectMake(core_.viewButtonsArea.frame.origin.x, core_.viewButtonsArea.frame.origin.y + offset, core_.viewButtonsArea.frame.size.width, [self.delegate heightForButtonsAreaOfAlert:self]);
    
    //change offset
    offset += core_.viewButtonsArea.frame.size.height - buttonsAreaSizeBefore;
    
    //increase the whole frame
    core_.frame = CGRectMake(0, 0, core_.frame.size.width, core_.frame.size.height + offset);
    
    //refresh the center
    core_.center = coreCenter;
    
    //save gap
    CGFloat coinsGap = CGRectGetMinX(core_.labelCoins.frame) - CGRectGetMaxX(core_.imageViewCoins.frame);
    
    //size label coins to fit
    core_.labelCoins.frame = CGRectMake(0, core_.labelCoins.frame.origin.y, [core_.labelCoins sizeThatFits:core_.labelCoins.frame.size].width, core_.labelCoins.frame.size.height);
    
    //align coins coins and image
    CGFloat bothSize = core_.labelCoins.frame.size.width + core_.imageViewCoins.frame.size.width + coinsGap;
    
    //change position
    core_.imageViewCoins.frame = CGRectMake(core_.frame.size.width/2 - bothSize/2, core_.imageViewCoins.frame.origin.y, core_.imageViewCoins.frame.size.width, core_.imageViewCoins.frame.size.height);
    core_.labelCoins.frame = CGRectMake(core_.imageViewCoins.frame.origin.x + core_.imageViewCoins.frame.size.width + coinsGap, core_.labelCoins.frame.origin.y, core_.labelCoins.frame.size.width, core_.labelCoins.frame.size.height);
    
    //add buttons
    for (int i = 0; i < [self.delegate numberOfButtonsOfAlert:self]; i++)
    {
        UIButton *button = [self.delegate buttonWithIndex:i ofAlert:self];
        if (button)
            [core_.viewButtonsArea addSubview:button];
    }
}

- (void)dealloc
{
    [core_ release];
    [message release];
    [title release];
    [viewCustomArea release];
    [labelMessage release];
    [viewButtonsArea release];
    [labelTitle release];
    [labelCoins release];
    [imageViewCoins release];
    [super dealloc];
}

@end
