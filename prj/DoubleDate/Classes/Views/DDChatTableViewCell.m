//
//  DDChatTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 1/18/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDChatTableViewCell.h"
#import "DDTools.h"
#import "DDMessage.h"
#import <QuartzCore/QuartzCore.h>

@implementation DDChatTableViewCell

@synthesize textView;
@synthesize imageViewBubble;
@synthesize labelTime;
@synthesize labelName;

@synthesize message;

@synthesize style;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    }
    return self;
}

- (void)customize
{    
    //unset text view background
    self.labelName.backgroundColor = [UIColor clearColor];
    self.labelTime.backgroundColor = [UIColor clearColor];
    self.textView.backgroundColor = [UIColor clearColor];
    
    self.textView.layer.shadowColor = [[UIColor whiteColor] CGColor];
    self.textView.layer.shadowOffset = CGSizeMake(0, 1);
    self.textView.layer.shadowOpacity = 0.3f;
    self.textView.layer.shadowRadius = 0;
    
    //save initial position
    rightPositionOfLastLabel_ = self.labelTime.frame.origin.x + self.labelTime.frame.size.width;
    labelsGap_ = self.labelTime.frame.origin.x - self.labelName.frame.origin.x - self.labelName.frame.size.width;
}

+ (CGFloat)heightForText:(NSString*)text
{
    DDChatTableViewCell *cell = (DDChatTableViewCell*)[[[UINib nibWithNibName:@"DDChatTableViewCell" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    CGFloat minHeight = cell.frame.size.height;
    cell.textView.text = text;
    return MAX(cell.frame.size.height - cell.textView.frame.size.height + cell.textView.contentSize.height + cell.textView.contentInset.top + cell.textView.contentInset.bottom, minHeight);
}

- (void)applyLabelsAlignment
{
    //check style
    if (self.style == DDChatTableViewCellStyleMe)
    {
        //update frame
        CGSize newLabelTimeSize = [self.labelTime sizeThatFits:self.labelTime.bounds.size];
        self.labelTime.frame = CGRectMake(rightPositionOfLastLabel_ - newLabelTimeSize.width, self.labelTime.frame.origin.y, newLabelTimeSize.width, self.labelTime.frame.size.height);
        
        //update frame
        CGSize newLabelNameSize = [self.labelName sizeThatFits:self.labelName.bounds.size];
        self.labelName.frame = CGRectMake(self.labelTime.frame.origin.x - labelsGap_ - newLabelNameSize.width, self.labelName.frame.origin.y, newLabelNameSize.width, self.labelName.frame.size.height);
    }
    else
    {
        //update frame
        CGSize newLabelNameSize = [self.labelName sizeThatFits:self.labelName.bounds.size];
        self.labelName.frame = CGRectMake(320 - rightPositionOfLastLabel_, self.labelName.frame.origin.y, newLabelNameSize.width, self.labelName.frame.size.height);
        
        //update frame
        CGSize newLabelTimeSize = [self.labelTime sizeThatFits:self.labelTime.bounds.size];
        self.labelTime.frame = CGRectMake(320 - rightPositionOfLastLabel_ + newLabelNameSize.width + labelsGap_, self.labelTime.frame.origin.y, newLabelTimeSize.width, self.labelTime.frame.size.height);
    }
}

- (void)setMessage:(DDMessage *)v
{
    //check the same value
    if (v != message)
    {
        //save value
        [message release];
        message = [v retain];
        
        //set message
        self.textView.text = v.message;
        
        //set time
        self.labelTime.text = [NSString stringWithFormat:@"%@ ago", v.createdAtAgo];
        
        //set name
        self.labelName.text = v.firstName;
        
        //apply labels alignment
        [self applyLabelsAlignment];
    }
}

- (void)setStyle:(DDChatTableViewCellStyle)v
{
    //set style
    style = v;
    
    //update bubble
    UIImage *imageBubble = [UIImage imageNamed:(v==DDChatTableViewCellStyleMe)?@"message-bubble-blue.png":@"message-bubble-gray.png"];
//    self.imageViewBubble.image = [imageBubble resizableImageWithCapInsets:UIEdgeInsetsMake(imageBubble.size.height/2-4, imageBubble.size.width/2, imageBubble.size.height/2+4, imageBubble.size.width/2)];

    self.imageViewBubble.image = [imageBubble resizableImageWithCapInsets:UIEdgeInsetsMake(14, imageBubble.size.width/2, 26, imageBubble.size.width/2)];
    
    //apply needed alignment
    [self applyLabelsAlignment];
    
    
    UIColor *softBlueTextColor = [UIColor colorWithRed:153.0f/255.0f green:212.0f/255.0f blue:235.0f/255.0f alpha:1.0f];
    
    if (v == DDChatTableViewCellStyleMe)
    {
        self.labelName.textColor = softBlueTextColor;
        self.labelTime.textColor = softBlueTextColor;
    }
    else
    {
        self.textView.textColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
        self.labelName.textColor = [UIColor grayColor];
        self.labelTime.textColor = [UIColor grayColor];
    }
}

- (void)dealloc
{
    [message release];
    [textView release];
    [imageViewBubble release];
    [labelTime release];
    [labelName release];
    [super dealloc];
}

@end
