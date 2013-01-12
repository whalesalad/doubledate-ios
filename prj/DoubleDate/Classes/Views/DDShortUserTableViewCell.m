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
@synthesize imageViewPoster;
@synthesize imageViewGender;
@synthesize imageViewCheckmark;

+ (CGFloat)height
{
    return 44;
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
    
    //set rounded corners
    imageViewPoster.layer.cornerRadius = 2;
    imageViewPoster.layer.masksToBounds = YES;
    
    //unset background
    labelLocation.backgroundColor = [UIColor clearColor];
    labelTitle.backgroundColor = [UIColor clearColor];
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
