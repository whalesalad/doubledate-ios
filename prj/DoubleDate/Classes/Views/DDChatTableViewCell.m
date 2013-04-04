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

#define kMinTextViewWidth 36
#define kMaxTextViewWidth 200

@implementation DDChatTableViewCell

@synthesize label;
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
    //disable selection
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //unset text view background
    self.labelName.backgroundColor = [UIColor clearColor];
    self.labelTime.backgroundColor = [UIColor clearColor];
    self.label.backgroundColor = [UIColor clearColor];
    
    self.label.layer.shadowColor = [[UIColor whiteColor] CGColor];
    self.label.layer.shadowOffset = CGSizeMake(0, 1);
    self.label.layer.shadowOpacity = 0.3f;
    self.label.layer.shadowRadius = 0;
    
    //save initial position
    rightPositionOfLastLabel_ = self.labelTime.frame.origin.x + self.labelTime.frame.size.width;
    labelsGap_ = self.labelTime.frame.origin.x - self.labelName.frame.origin.x - self.labelName.frame.size.width;
    labelFrame_ = self.label.frame;
    imageViewFrame_ = self.imageViewBubble.frame;
    
    //update text view color
    self.label.textColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
}

- (void)prepareForReuse
{
    self.label.frame = labelFrame_;
    self.imageViewBubble.frame = imageViewFrame_;
}

+ (CGFloat)heightForText:(NSString*)text
{
    DDChatTableViewCell *cell = (DDChatTableViewCell*)[[[UINib nibWithNibName:@"DDChatTableViewCell" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    CGFloat minHeight = cell.frame.size.height;
    CGSize size = [text sizeWithFont:cell.label.font constrainedToSize:CGSizeMake(kMaxTextViewWidth, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return MAX(cell.frame.size.height - cell.label.frame.size.height + size.height, minHeight);
}

- (BOOL)isRightAligned
{
    return (self.style == DDChatTableViewCellStyleMe);
}

- (void)alignBubble
{
    //align text
    self.label.textAlignment = [self isRightAligned]?NSTextAlignmentRight:NSTextAlignmentLeft;
    
    //align position
    if ([self isRightAligned])
    {
        CGFloat offset = 320 - CGRectGetMaxX(self.label.frame) - self.label.frame.origin.x;
        self.label.center = CGPointMake(self.label.center.x + offset, self.label.center.y);
    }
    
    //align bubble
    CGFloat dw = labelFrame_.size.width - self.label.frame.size.width;
    self.imageViewBubble.frame = CGRectMake(self.imageViewBubble.frame.origin.x, self.imageViewBubble.frame.origin.y, imageViewFrame_.size.width - dw, self.imageViewBubble.frame.size.height);
    if ([self isRightAligned])
        self.imageViewBubble.center = CGPointMake(320 - self.imageViewBubble.center.x, self.imageViewBubble.center.y);
}

- (void)customizeBubble
{
    //save label size
    CGSize newLabelSize = [self.message.message sizeWithFont:self.label.font constrainedToSize:CGSizeMake(kMaxTextViewWidth, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    //update the number of label lines
    self.label.numberOfLines = newLabelSize.height / self.label.font.pointSize;
    
    //check if less
    if (self.label.numberOfLines <= 1 && newLabelSize.width < kMinTextViewWidth)
        newLabelSize.width = kMinTextViewWidth;
    
    //update frame
    self.label.frame = CGRectMake(self.label.frame.origin.x, self.label.frame.origin.y, newLabelSize.width, newLabelSize.height);
    
    //apply bubble alignment
    [self alignBubble];
}

- (void)alignLabels
{
    //save sizes
    CGSize newLabelTimeSize = [self.labelTime frame].size;
    CGSize newLabelNameSize = [self.labelName frame].size;
    
    //check style
    if (self.style == DDChatTableViewCellStyleMe)
    {
        //update frame
        self.labelTime.frame = CGRectMake(rightPositionOfLastLabel_ - newLabelTimeSize.width, self.labelTime.frame.origin.y, newLabelTimeSize.width, self.labelTime.frame.size.height);
        
        //update frame
        self.labelName.frame = CGRectMake(self.labelTime.frame.origin.x - labelsGap_ - newLabelNameSize.width, self.labelName.frame.origin.y, newLabelNameSize.width, self.labelName.frame.size.height);
    }
    else
    {
        //update frame
        self.labelName.frame = CGRectMake(320 - rightPositionOfLastLabel_, self.labelName.frame.origin.y, newLabelNameSize.width, self.labelName.frame.size.height);
        
        //update frame
        self.labelTime.frame = CGRectMake(320 - rightPositionOfLastLabel_ + newLabelNameSize.width + labelsGap_, self.labelTime.frame.origin.y, newLabelTimeSize.width, self.labelTime.frame.size.height);
    }
}

- (void)customizeLabels
{
    //update time
    NSString *time = [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @"Chat time ago"), self.message.createdAtAgo];
    CGSize newLabelTimeSize = [time sizeWithFont:self.labelTime.font constrainedToSize:CGSizeMake(FLT_MAX, 0) lineBreakMode:self.labelTime.lineBreakMode];
    self.labelTime.text = time;
    self.labelTime.frame = CGRectMake(self.labelTime.frame.origin.x, self.labelTime.frame.origin.y, newLabelTimeSize.width, newLabelTimeSize.height);
    
    //set values
    NSString *name = self.message.firstName;
    CGSize newLabelNameSize = [name sizeWithFont:self.labelName.font constrainedToSize:CGSizeMake(FLT_MAX, 0) lineBreakMode:self.labelName.lineBreakMode];
    self.labelName.text = name;
    self.labelName.frame = CGRectMake(self.labelName.frame.origin.x, self.labelName.frame.origin.y, newLabelNameSize.width, newLabelNameSize.height);
    
    //align labels
    [self alignLabels];
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
        self.label.text = v.message;
        
        //customize bubble
        [self customizeBubble];
        
        //apply labels alignment
        [self customizeLabels];
    }
}

- (void)setStyle:(DDChatTableViewCellStyle)v
{
    //set style
    style = v;
    
    //update bubble
    UIImage *imageBubble = [UIImage imageNamed:(v==DDChatTableViewCellStyleMe)?@"message-bubble-blue.png":@"message-bubble-gray.png"];
    if ([self isRightAligned])
        imageBubble = [UIImage imageWithCGImage:imageBubble.CGImage scale:imageBubble.scale orientation:UIImageOrientationUpMirrored];
    self.imageViewBubble.image = [imageBubble resizableImageWithCapInsets:UIEdgeInsetsMake(14, 5, 26, 20)];
    
    //update colors
    if ([self isRightAligned])
    {
        UIColor *color = [UIColor colorWithRed:153.0f/255.0f green:212.0f/255.0f blue:235.0f/255.0f alpha:1.0f];
        self.labelName.textColor = color;
        self.labelTime.textColor = color;
    }
    else
    {
        UIColor *color = [UIColor grayColor];
        self.labelName.textColor = color;
        self.labelTime.textColor = color;
    }
    
    //update alignment
    [self alignLabels];
    [self alignBubble];
}

- (void)dealloc
{
    [message release];
    [label release];
    [imageViewBubble release];
    [labelTime release];
    [labelName release];
    [super dealloc];
}

@end
