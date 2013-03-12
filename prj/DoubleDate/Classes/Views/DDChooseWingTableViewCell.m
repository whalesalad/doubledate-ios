//
//  DDChooseWingTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDChooseWingTableViewCell.h"
#import "DDShortUser.h"
#import "DDImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DDChooseWingTableViewCell

@synthesize imageViewUser;
@synthesize labelName;

@synthesize shortUser;

+ (CGFloat)height
{
    return 100;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)customizeOnce
{
}

- (void)setShortUser:(DDShortUser *)v
{
    //apply new value
    if (v != shortUser)
    {
        [shortUser release];
        shortUser = [v retain];
    }
    
    //set image view
    [self.imageViewUser reloadFromUrl:[NSURL URLWithString:shortUser.photo.smallUrl]];
    
    //set label
    self.labelName.text = shortUser.firstName;
}

- (void)dealloc
{
    [imageViewUser release];
    [labelName release];
    [shortUser release];
    [super dealloc];
}

@end
