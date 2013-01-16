//
//  DDShortUserTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDShortUserTableViewCell.h"
#import "DDShortUser.h"
#import "DDImageView.h"
#import "DDWingTableViewCell.h"
#import "DDUser.h"
#import "DDTools.h"
#import <QuartzCore/QuartzCore.h>

@implementation DDShortUserTableViewCell

@synthesize shortUser;

@synthesize labelTitle;
@synthesize labelLocation;
@synthesize imageViewWrapper;
@synthesize imageViewPoster;
@synthesize imageViewGender;
@synthesize imageViewCheckmark;

+ (CGFloat)height
{
    return 50;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //set background view
    self.backgroundView = [[[UIImageView alloc] initWithImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"dark-tableview-bg.png"]]] autorelease];
    
    //hide checkmark
    imageViewCheckmark.hidden = YES;
    
    imageViewWrapper.layer.borderColor = [UIColor blackColor].CGColor;
    imageViewWrapper.layer.borderWidth = 1;
    imageViewWrapper.layer.cornerRadius = 2;
    
    imageViewWrapper.layer.shadowColor = [UIColor blackColor].CGColor;
    imageViewWrapper.layer.shadowOffset = CGSizeMake(0, 1);
    imageViewWrapper.layer.shadowRadius = 1;
    imageViewWrapper.layer.shadowOpacity = 0.5f;
    // imageViewWrapper.layer.shadowPath = [[UIBezierPath bezierPathWithRect:viewEffects.bounds] CGPath];
    
    // set rounded corners
    // tighter radius on inner layer = no tiny pixel artifacts on corner
    imageViewPoster.layer.cornerRadius = 3;
    imageViewPoster.layer.masksToBounds = YES;
    
    // Add an inner white border on the top only
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 1, imageViewPoster.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor whiteColor].CGColor;
    topBorder.opacity = 0.2f;
    [imageViewPoster.layer addSublayer:topBorder];
    
    //unset background
    labelLocation.backgroundColor = [UIColor clearColor];
    labelTitle.backgroundColor = [UIColor clearColor];
    
    //customize poster
    [[imageViewPoster layer] setMagnificationFilter:kCAFilterNearest];
    imageViewPoster.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setShortUser:(DDShortUser *)v
{
    //apply new value
    if (v != shortUser)
    {
        [shortUser release];
        shortUser = [v retain];
    }
    
    //update ui
    imageViewPoster.image = nil;
    if (v.photo.thumbUrl && [NSURL URLWithString:v.photo.thumbUrl])
        [imageViewPoster reloadFromUrl:[NSURL URLWithString:v.photo.thumbUrl]];

    labelTitle.text = [DDWingTableViewCell titleForShortUser:v];
    labelTitle.frame = CGRectMake(labelTitle.frame.origin.x, labelTitle.frame.origin.y, [labelTitle sizeThatFits:labelTitle.bounds.size].width, labelTitle.frame.size.height);
    
    labelLocation.text = v.location;
    
    if ([[v gender] isEqualToString:DDUserGenderFemale])
        imageViewGender.image = [UIImage imageNamed:@"icon-gender-female.png"];
    else
        imageViewGender.image = [UIImage imageNamed:@"icon-gender-male.png"];
    imageViewGender.frame = CGRectMake(labelTitle.frame.origin.x+labelTitle.frame.size.width+4, labelTitle.center.y-imageViewGender.image.size.height/2, imageViewGender.image.size.width, imageViewGender.image.size.height);
}

- (void)dealloc
{
    [shortUser release];
    [labelTitle release];
    [labelLocation release];
    [imageViewPoster release];
    [imageViewGender release];
    [imageViewCheckmark release];
    [super dealloc];
}

@end
