//
//  DDDoubleDateTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDateTableViewCell.h"
#import "DDImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "DDDoubleDate.h"
#import "DDImage.h"
#import "DDShortUser.h"
#import "DDPlacemark.h"
#import "DDTools.h"

@implementation DDDoubleDateTableViewCell

@synthesize doubleDate;

@synthesize imageViewUser;
@synthesize imageViewWing;
@synthesize viewEffects;
@synthesize labelTitle;
@synthesize labelLocation;
@synthesize viewImagesContainer;

+ (CGFloat)height
{
    return 108;
}

+ (NSString*)detailedTitleForLocation:(DDPlacemark*)location
{
    if ([location.type isEqualToString:DDPlacemarkTypeVenue])
        return [NSString stringWithFormat:@"%@ • %@", location.venue, location.locationName];
    return location.name;
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
    
    viewEffects.layer.borderColor = [UIColor blackColor].CGColor;
    viewEffects.layer.borderWidth = 1;

    viewEffects.layer.shadowColor = [UIColor blackColor].CGColor;
    viewEffects.layer.shadowOffset = CGSizeMake(0, 1);
    viewEffects.layer.shadowRadius = 1;
    viewEffects.layer.shadowOpacity = 0.4f;
    viewEffects.layer.shadowPath = [[UIBezierPath bezierPathWithRect:viewEffects.bounds] CGPath];
    
    viewImagesContainer.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1].CGColor;
    viewImagesContainer.layer.borderWidth = 1;
    
    //unset background
    labelLocation.backgroundColor = [UIColor clearColor];
    labelTitle.backgroundColor = [UIColor clearColor];
}

- (void)setDoubleDate:(DDDoubleDate *)v
{
    //update double date
    if (doubleDate != v)
    {
        [doubleDate release];
        doubleDate = [v retain];
    }
    
    //apply photos
    [imageViewUser reloadFromUrl:[NSURL URLWithString:doubleDate.user.photo.smallUrl]];
    [imageViewWing reloadFromUrl:[NSURL URLWithString:doubleDate.wing.photo.smallUrl]];
    
    //apply text
    labelTitle.text = [v title];
    
    //apply location
    labelLocation.text = [DDDoubleDateTableViewCell detailedTitleForLocation:v.location];
}

- (void)dealloc
{
    [doubleDate release];
    [imageViewUser release];
    [imageViewWing release];
    [viewEffects release];
    [labelTitle release];
    [labelLocation release];
    [viewImagesContainer release];
    [super dealloc];
}

@end
