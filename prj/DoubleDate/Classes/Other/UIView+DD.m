//
//  UIView+DD.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "UIView+DD.h"
#import "UIImage+DD.h"
#import "DDUser.h"
#import "DDInterest.h"
#import <QuartzCore/QuartzCore.h>

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
            label.text = interest.name;
            if (custmomizationHandler)
                custmomizationHandler(label);
            [label sizeToFit];
            
            //create background image
            UIImage *labelBackgroundImage = [[interest matched] boolValue]?matchedBubbleImage:bubbleImage;
            UIImageView *labelBackground = [[[DDInterestViewInternal alloc] initWithFrame:CGRectMake(curX, curY, label.frame.size.width+2*inEdgePadding, labelBackgroundImage.size.height)] autorelease];
            labelBackground.image = [labelBackgroundImage resizableImage];
            
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
        [mainView addSubview:label];
        
        return mainView.frame.size.height + 14;
    }
}

@end

@implementation UIView (Other)

- (UIButton*)baseButtonWithImage:(UIImage*)image
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    button.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1f];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    button.titleEdgeInsets = UIEdgeInsetsMake(1, 40, 0, 0);
    return button;
}

- (void)customizeTitleLabel:(UILabel*)label
{
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    label.textColor = [UIColor colorWithWhite:0.38f alpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.shadowOffset = CGSizeMake(0, 1);
    label.layer.shadowOpacity = 0.5f;
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowRadius = 1;
    label.layer.masksToBounds = NO;
}

- (void)customizeGenericLabel:(UILabel*)label
{
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
    label.textColor = [UIColor colorWithWhite:0.4f alpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.shadowOffset = CGSizeMake(0, 1);
    label.layer.shadowOpacity = 0.5f;
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowRadius = 1;
    label.layer.masksToBounds = NO;
}

- (void)applyNoDataWithImage:(UIImage*)image title:(NSString*)title addButtonTitle:(NSString*)buttonTitle addButtonTarget:(id)target addButtonAction:(SEL)action addButtonEdgeInsets:(UIEdgeInsets)insets detailed:(NSString*)detailed
{
    
    //add image view
    UIImageView *imageViewTop = [[[UIImageView alloc] initWithImage:image] autorelease];
    imageViewTop.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    UILabel *labelTop = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 60)] autorelease];
    labelTop.numberOfLines = 2;
    labelTop.text = title;
    labelTop.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self customizeTitleLabel:labelTop];
    
    UIView *upperView = [[[UIView alloc] initWithFrame:CGRectMake(20, 120, 280, imageViewTop.frame.size.height + labelTop.frame.size.height + 20)] autorelease];
    
    CGRect labelFrame = upperView.bounds;
    labelFrame.size.height = 75;
    labelFrame.origin.y = upperView.frame.size.height - labelFrame.size.height;
    labelTop.frame = labelFrame;
    
    CGRect imageFrame = imageViewTop.frame;
    imageFrame.origin.x = upperView.frame.size.width/2 - imageFrame.size.width/2;
    imageViewTop.frame = imageFrame;
    
    [upperView addSubview:imageViewTop];
    [upperView addSubview:labelTop];
    
    //add label
    [self addSubview:upperView];
    
    // Center the label if there is no image (simple style, like no notifications)
    if (!image) {
        upperView.center = self.center;
    }
    
    UIView *lowerView = [[[UIView alloc] initWithFrame:CGRectMake(20, self.frame.size.height - 160, 280, 120)] autorelease];
    
    // add create date button
    if (buttonTitle && target && action)
    {
        UIImage *imageButton = [UIImage imageNamed:@"btn-blue-create.png"];
        UIButton *button = [self baseButtonWithImage:imageButton];
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        [lowerView addSubview:button];
        
        //add gradient background
        UIImageView *gradientView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-no-dates-centered.png"]] autorelease];
        gradientView.frame = CGRectMake(0, 0, 320, gradientView.image.size.height);
        gradientView.center = CGPointMake(button.center.x, button.center.y + 30);
        [lowerView insertSubview:gradientView belowSubview:button];
        
        //add label
        UILabel *labelBottom = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 60)] autorelease];
        labelBottom.center = CGPointMake(button.center.x, button.center.y + 55);
        labelBottom.numberOfLines = 2;
        labelBottom.text = detailed;
        [self customizeGenericLabel:labelBottom];
        
        [lowerView addSubview:labelBottom];
        
    }
    
    [self addSubview:lowerView];
    
}

- (void)applyNoDataWithMainText:(NSString*)mainText infoText:(NSString*)infoText
{
    //create main label
    UILabel *labelMain = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0)] autorelease];
    
    labelMain.backgroundColor = [UIColor clearColor];
    labelMain.text = mainText;
    labelMain.textAlignment = NSTextAlignmentCenter;
    
    [self customizeTitleLabel:labelMain];
    
    CGSize newLabelMainSize = [mainText sizeWithFont:labelMain.font
                                   constrainedToSize:CGSizeMake(labelMain.frame.size.width, FLT_MAX)
                                       lineBreakMode:NSLineBreakByWordWrapping];
    
    labelMain.numberOfLines = newLabelMainSize.height / labelMain.font.pointSize;
    labelMain.frame = CGRectMake(0, 0, newLabelMainSize.width, newLabelMainSize.height);
    labelMain.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2 - newLabelMainSize.height/2);
    
    [self addSubview:labelMain];
    
    if (infoText) {
        //create detailed label
        UILabel *labelDetailed = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0)] autorelease];
        
        labelDetailed.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3f];
        labelDetailed.text = infoText;
        labelDetailed.textAlignment = NSTextAlignmentCenter;
        
        labelDetailed.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
        labelDetailed.textColor = [UIColor lightGrayColor];
        
        CGSize newLabelDetailedSize = [infoText sizeWithFont:labelDetailed.font
                                           constrainedToSize:CGSizeMake(labelDetailed.frame.size.width - 20, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        
        newLabelDetailedSize.height += 20;
        
        labelDetailed.numberOfLines = newLabelDetailedSize.height / labelDetailed.font.pointSize;
        labelDetailed.frame = CGRectMake(0, 0, self.bounds.size.width - 40, newLabelDetailedSize.height);
        labelDetailed.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height * 0.75 - newLabelDetailedSize.height/2);
        
        labelDetailed.layer.cornerRadius = newLabelDetailedSize.height / 2;
        
        [self addSubview:labelDetailed];
    }
}

- (UIButton*)lowerButtonWithTitle:(NSString*)title backgroundImage:(UIImage*)background
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // Set title
    [button setTitle:title forState:UIControlStateNormal];
    
    // Customize title
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    button.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5f];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    
    // Set background
    button.frame = CGRectMake(0, 0, 100, background.size.height);
    [button setBackgroundImage:[background resizableImage] forState:UIControlStateNormal];
    
    return button;
}

- (UIButton*)lowerGrayButtonWithTitle:(NSString*)title
{
    return [self lowerButtonWithTitle:title
                      backgroundImage:[UIImage imageNamed:@"lower-button-gray.png"]];
}

- (UIButton*)lowerBlueButtonWithTitle:(NSString*)title
{
    return [self lowerButtonWithTitle:title
                      backgroundImage:[UIImage imageNamed:@"lower-button-blue.png"]];
}

@end
