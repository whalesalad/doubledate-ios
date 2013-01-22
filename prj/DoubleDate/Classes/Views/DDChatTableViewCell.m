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

@implementation DDChatTableViewCell

@synthesize textView;
@synthesize imageViewBubble;
@synthesize labelTime;
@synthesize labelName;

@synthesize message;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //set background view
    UIImage *imageBubble = self.imageViewBubble.image;
    self.imageViewBubble.image = [imageBubble resizableImageWithCapInsets:UIEdgeInsetsMake(imageBubble.size.height/2-4, imageBubble.size.width/2, imageBubble.size.height/2+4, imageBubble.size.width/2)];
    
    //unset text view background
    self.textView.backgroundColor = [UIColor clearColor];
}

+ (CGFloat)heightForText:(NSString*)text
{
    DDChatTableViewCell *cell = (DDChatTableViewCell*)[[[UINib nibWithNibName:@"DDChatTableViewCell" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    cell.textView.text = text;
    return cell.frame.size.height - cell.textView.frame.size.height + cell.textView.contentSize.height;
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
        self.labelTime.text = v.createdAtAgo;
        
        //update frame
        CGFloat oldLabelTimeX = self.labelTime.frame.origin.x;
        CGSize newLabelTimeSize = [self.labelTime sizeThatFits:self.labelTime.bounds.size];
        self.labelTime.frame = CGRectMake(self.labelTime.frame.origin.x - newLabelTimeSize.width + self.labelTime.frame.size.width, self.labelTime.frame.origin.y, newLabelTimeSize.width, self.labelTime.frame.size.height);
        
        //set name
        self.labelName.text = v.firstName;
        
        //update frame
        CGSize newLabelNameSize = [self.labelName sizeThatFits:self.labelName.bounds.size];
        CGFloat labelTimeOffset = oldLabelTimeX - self.labelTime.frame.origin.x;
        self.labelName.frame = CGRectMake(self.labelName.frame.origin.x - newLabelNameSize.width + self.labelName.frame.size.width - labelTimeOffset, self.labelName.frame.origin.y, newLabelNameSize.width, self.labelName.frame.size.height);
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
