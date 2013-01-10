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

+ (CGFloat)height
{
    return 100;
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
    
#warning customize here
    viewEffects.layer.borderColor = [UIColor blackColor].CGColor;
    viewEffects.layer.borderWidth = 1;
    
    viewEffects.layer.shadowColor = [UIColor blackColor].CGColor;
    viewEffects.layer.shadowOffset = CGSizeMake(0, 1);
    viewEffects.layer.shadowRadius = 1;
    viewEffects.layer.shadowOpacity = 0.9f;
    
    imageViewUser.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1].CGColor;
    imageViewUser.layer.borderWidth = 1;
    
    imageViewWing.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1].CGColor;
    imageViewWing.layer.borderWidth = 1;
    
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
    [super dealloc];
}

@end
