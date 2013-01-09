//
//  UIView+Interests.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "UIView+Interests.h"
#import "DDInterest.h"
#import "DDTools.h"

@interface DDInterestViewInternal : UIView
@end

@implementation DDInterestViewInternal
@end

@implementation UIView (Interests)

- (CGFloat)applyInterests:(NSArray*)interests withBubbleImage:(UIImage*)bubbleImage custmomizationHandler:(void (^)(UILabel *bubbleLabel))custmomizationHandler
{
    //remove all interests
    NSMutableArray *viewsToRemove = [NSMutableArray array];
    for (UIView *v in [self subviews])
    {
        if ([v isKindOfClass:[DDInterestViewInternal class]])
            [viewsToRemove addObject:v];
    }
    while ([viewsToRemove count])
    {
        UIView *v = [viewsToRemove lastObject];
        [v removeFromSuperview];
        [viewsToRemove removeObject:v];
    }
    
    //add interesets
    CGFloat outHorPadding = 4;
    CGFloat outVerPadding = 6;
    CGFloat curX = outHorPadding;
    CGFloat curY = outVerPadding;
    CGFloat totalInterestsHeight = 0;
    for (DDInterest *interest in interests)
    {
        //edge padding inside the bubble
        CGFloat inEdgePadding = 6;
        
        //create label
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        
        //apply label text
        label.text = [interest.name uppercaseString];
        if (custmomizationHandler)
            custmomizationHandler(label);
        [label sizeToFit];
        
        //create background image
        UIImageView *labelBackground = [[[UIImageView alloc] initWithFrame:CGRectMake(curX, curY, label.frame.size.width+2*inEdgePadding, bubbleImage.size.height)] autorelease];
        labelBackground.image = [DDTools resizableImageFromImage:bubbleImage];
        
        //add label
        label.center = CGPointMake(labelBackground.frame.size.width/2, labelBackground.frame.size.height/2);
        [labelBackground addSubview:label];
        
        //add image view
        [self addSubview:labelBackground];
        
        //move horizontally
        curX = labelBackground.frame.origin.x + labelBackground.frame.size.width + outHorPadding;
        
        //check if out of the bounds
        if (curX > self.frame.size.width)
        {
            //update current frame
            curY = labelBackground.frame.origin.y + labelBackground.frame.size.height + outVerPadding;
            curX = outHorPadding;
            labelBackground.frame = CGRectMake(curX, curY, labelBackground.frame.size.width, labelBackground.frame.size.height);
            
            //set up new frame
            curX = labelBackground.frame.origin.x + labelBackground.frame.size.width + outHorPadding;
        }
        
        //save total height
        totalInterestsHeight = labelBackground.frame.origin.y + labelBackground.frame.size.height + outVerPadding;
    }
    CGFloat newInterestsHeight = totalInterestsHeight;
    
    //maximum 6 rows + 7 paddings
    newInterestsHeight = MIN(MAX(newInterestsHeight, 0), 27*6+outVerPadding*7) + 4;
    
    return newInterestsHeight;
}

@end
