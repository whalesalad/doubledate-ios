//
//  UIView+Interests.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "UIView+Interests.h"
#import "DDInterest.h"
#import "DDTools.h"
#import "DDUser.h"

@interface DDInterestViewInternal : UIImageView
@end

@implementation DDInterestViewInternal
@end

@implementation UIView (Interests)

- (CGFloat)applyInterestsForUser:(DDUser*)user bubbleImage:(UIImage*)bubbleImage matchedBubbleImage:(UIImage*)matchedBubbleImage custmomizationHandler:(void (^)(UILabel *bubbleLabel))custmomizationHandler
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
    
    //initial parameters
    CGFloat outHorPadding = 4;
    CGFloat outVerPadding = 6;
    
    //save interests
    NSArray *interests = user.interests;
    
    //check if interests are exist
    if ([interests count])
    {
        //initial parameters
        CGFloat curX = outHorPadding;
        CGFloat curY = outVerPadding;
        CGFloat totalInterestsHeight = 0;
        
        //add interesets
        for (DDInterest *interest in interests)
        {
            //edge padding inside the bubble
            CGFloat inEdgePadding = 7;
            
            //create label
            UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
            
            //apply label text
            //temporarily disabling uppercasing..
            //label.text = [interest.name uppercaseString];
            label.text = interest.name;
            if (custmomizationHandler)
                custmomizationHandler(label);
            [label sizeToFit];
            
            //create background image
            UIImage *labelBackgroundImage = [[interest matched] boolValue]?matchedBubbleImage:bubbleImage;
            UIImageView *labelBackground = [[[DDInterestViewInternal alloc] initWithFrame:CGRectMake(curX, curY, label.frame.size.width+2*inEdgePadding, labelBackgroundImage.size.height)] autorelease];
            labelBackground.image = [DDTools resizableImageFromImage:labelBackgroundImage];
            
            //add label
            label.center = CGPointMake(labelBackground.frame.size.width/2, labelBackground.frame.size.height/2 - 1);
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
    else
    {
        //add background view
        DDInterestViewInternal *mainView = [[[DDInterestViewInternal alloc] initWithFrame:CGRectMake(0, outVerPadding, self.frame.size.width, 30)] autorelease];
        [self addSubview:mainView];
        
        //add label
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectInset(mainView.bounds, 4, 0)] autorelease];
        label.text = [NSString stringWithFormat:NSLocalizedString(@"%@ doesn't have any ice breakers.", @"Text for when a user/wing doesn't have ice breakers"), user.firstName];
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        label.textColor = [UIColor lightGrayColor];
        label.backgroundColor = [UIColor clearColor];
//        label.shadowColor = [UIColor blackColor];
//        label.shadowOffset = CGSizeMake(0, -1);
        [mainView addSubview:label];
        
        return mainView.frame.size.height + 14;
    }
}

@end
