//
//  DDLocationTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDLocationTableViewCell.h"
#import "DDPlacemark.h"
#import "DDTools.h"

@implementation DDLocationTableViewCell

@synthesize location;

+ (NSString*)mainTitleForLocation:(DDPlacemark*)location
{
    if (location.name)
        return location.name;
    return @"";
}

+ (NSString*)detailedTitleForLocation:(DDPlacemark*)location
{
    NSMutableString *text = [NSMutableString stringWithString:@""];
    if ([location address])
        [text appendFormat:@"%@ ", location.address];
    if (location.locationName)
        [text appendString:location.locationName];
    return text;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
    }
    return self;
}

- (void)setLocation:(DDPlacemark *)v
{
    //save value
    if (v != location)
    {
        [location release];
        location = [v retain];
    }
    
    //set text
    self.textLabel.text = [DDLocationTableViewCell mainTitleForLocation:location];
    
    //check for venue
    self.detailTextLabel.text = [DDLocationTableViewCell detailedTitleForLocation:location];
}

- (void)dealloc
{
    [location release];
    [super dealloc];
}

@end
