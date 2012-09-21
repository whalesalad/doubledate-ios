//
//  DDTagsView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTagsView.h"

@implementation DDTagsView

@synthesize image;
@synthesize tags;

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)initSelf
{
    self.image = [UIImage imageNamed:@"userinfo_interests_bg.png"];
    self.font = [UIFont systemFontOfSize:13];
    self.textColor = [UIColor blackColor];
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

- (void)customize
{
    //generate lines
    NSMutableArray *lines = [NSMutableArray array];
    NSMutableString *line = [NSMutableString string];
    NSString *endCharacter = @" • ";
    for (NSString *word in self.tags)
    {
        if ([[line stringByAppendingFormat:@"%@%@", endCharacter, word] sizeWithFont:self.font].width >= self.frame.size.width)
        {
            [lines addObject:line];
            line = [NSMutableString stringWithFormat:@"%@%@", endCharacter, word];
        }
        else
            [line appendFormat:@"%@%@", endCharacter, word];
    }
    [lines addObject:line];
    NSMutableArray *correctedLines = [NSMutableArray array];
    for (NSString *initLine in lines)
    {
        NSString *resLine = [NSString stringWithString:initLine];
        while ([resLine rangeOfString:endCharacter].location == 0)
            resLine = [resLine substringFromIndex:endCharacter.length];
        [correctedLines addObject:resLine];
    }
    
    //remove all childs
    while ([[self subviews] count])
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    
    //check for new labels
    if ([correctedLines count])
    {
        //set line size
        CGSize lineSize = [@"Ay"sizeWithFont:self.font];
        
        //apply offset
        CGFloat offset = (self.frame.size.height - [correctedLines count] * lineSize.height - ([correctedLines count] - 1) * self.gap) / 2;
        
        //set bubble padding
        CGFloat bubblePadding = 12;
        
        //calculate bubble size
        CGSize bubbleSize = CGSizeMake(self.frame.size.width, (lineSize.height + self.gap) * [correctedLines count] + 2 * bubblePadding);
                
        //create image view
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:[self.image resizableImageWithCapInsets:self.bubbleEdgeInsets]] autorelease];
        imageView.frame = CGRectMake(0, 0, bubbleSize.width, bubbleSize.height);
        imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:imageView];
        
        //create labels
        for (NSString *lineToAdd in correctedLines)
        {
            UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, [correctedLines indexOfObject:lineToAdd] * (lineSize.height + self.gap) + offset - self.gap/2, self.frame.size.width, lineSize.height + self.gap)] autorelease];
            label.backgroundColor = [UIColor clearColor];
            label.text = lineToAdd;
            label.textAlignment = UITextAlignmentCenter;
            label.font = self.font;
            label.textColor = self.textColor;
            [self addSubview:label];
        }
    }
}

- (void)dealloc
{
    [image release];
    [tags release];
    [super dealloc];
}

@end
