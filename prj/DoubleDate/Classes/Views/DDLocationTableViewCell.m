//
//  DDLocationTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDLocationTableViewCell.h"
#import "DDPlacemark.h"
#import "DDTools.h"

@implementation DDLocationTableViewCell

@synthesize location;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        self.textLabel.font = [DDTools boldAvenirFontOfSize:18];
        self.textLabel.textColor = [UIColor whiteColor];
        self.detailTextLabel.font = [DDTools boldAvenirFontOfSize:14];
        self.detailTextLabel.textColor = [UIColor grayColor];
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
    self.textLabel.text = [location name];
    
    //check for venue
    if ([location.type isEqualToString:DDPlacemarkTypeVenue])
    {
        NSMutableString *text = [NSMutableString stringWithString:@""];
        if ([location address])
            [text appendFormat:@"%@ ", location.address];
        if (location.locationName)
            [text appendString:location.locationName];
        self.detailTextLabel.text = text;
    }
    else
        self.detailTextLabel.text = nil;
}

- (void)dealloc
{
    [location release];
    [super dealloc];
}

@end
