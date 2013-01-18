//
//  DDChatTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 1/18/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDChatTableViewCell.h"
#import "DDTools.h"

@implementation DDChatTableViewCell

@synthesize textView;
@synthesize imageViewBubble;
@synthesize labelTime;
@synthesize labelName;

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

- (void)setText:(NSString *)text
{
    self.textView.text = text;
    
    if (rand() % 2 == 0)
        self.labelTime.text = @"1 minues ago";
    else
        self.labelTime.text = @"now";
    
    CGFloat oldLabelTimeX = self.labelTime.frame.origin.x;
    CGSize newLabelTimeSize = [self.labelTime sizeThatFits:self.labelTime.bounds.size];
    self.labelTime.frame = CGRectMake(self.labelTime.frame.origin.x - newLabelTimeSize.width + self.labelTime.frame.size.width, self.labelTime.frame.origin.y, newLabelTimeSize.width, self.labelTime.frame.size.height);
    
    if (rand() % 2 == 0)
        self.labelName.text = @"Gennadii";
    else
        self.labelName.text = @"Some very long name";
    
    CGSize newLabelNameSize = [self.labelName sizeThatFits:self.labelName.bounds.size];
    CGFloat labelTimeOffset = oldLabelTimeX - self.labelTime.frame.origin.x;
    self.labelName.frame = CGRectMake(self.labelName.frame.origin.x - newLabelNameSize.width + self.labelName.frame.size.width - labelTimeOffset, self.labelName.frame.origin.y, newLabelNameSize.width, self.labelName.frame.size.height);
}

- (NSString*)text
{
    return self.textView.text;
}

- (void)dealloc
{
    [textView release];
    [imageViewBubble release];
    [labelTime release];
    [labelName release];
    [super dealloc];
}

@end
