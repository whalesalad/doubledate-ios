//
//  DDUserTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDUserTableViewCell.h"
#import "DDShortUser.h"
#import "DDImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DDUserTableViewCell

@synthesize type;

@synthesize shortUser;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        labelMain_ = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        labelMain_.font = [UIFont boldSystemFontOfSize:16];
        labelMain_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:labelMain_];
        
        labelDetails_ = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        labelDetails_.font = [UIFont systemFontOfSize:14];
        labelDetails_.textColor = [UIColor grayColor];
        labelDetails_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:labelDetails_];
        
        imageView_ = [[[DDImageView alloc] initWithFrame:CGRectZero] autorelease];
        imageView_.contentMode = UIViewContentModeCenter;
        imageView_.layer.cornerRadius = 19;
        imageView_.layer.masksToBounds = YES;
        imageView_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:imageView_];
        
        overlayImageView_ = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user-photo-overlay.png"]] autorelease];
        overlayImageView_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:overlayImageView_];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [imageView_ setFrame:CGRectMake(11, 6, 38, 38)];
    [overlayImageView_ setFrame:CGRectMake(10, 5, 41, 41)];
    
    if (self.type == DDUserTableViewCellTypeWings)
    {
        [labelMain_ setFrame:CGRectMake(60, 6, 225, 22)];
        [labelDetails_ setFrame:CGRectMake(60, 28, 225, 15)];
    }
    else if (self.type == DDUserTableViewCellTypeInvitations)
    {
        [labelMain_ setFrame:CGRectMake(60, 6, 195, 22)];
        [labelDetails_ setFrame:CGRectMake(60, 28, 195, 15)];
    }
    else if (self.type == DDUserTableViewCellTypeFacebook)
    {
        [labelMain_ setFrame:CGRectMake(60, 6, 205, 22)];
        [labelDetails_ setFrame:CGRectMake(60, 28, 205, 15)];
    }
}

- (void)setShortUser:(DDShortUser *)v
{
    //check for the same instance
    if (v != shortUser)
    {
        //update value
        [shortUser release];
        shortUser = [v retain];
        
        //check friend
        if (shortUser)
        {
            //show all
            [labelMain_ setHidden:NO];
            [labelDetails_ setHidden:NO];
            [imageView_ setHidden:NO];
            
            //set text
            NSString *mainText = nil;
            if (shortUser.fullName)
                mainText = shortUser.fullName;
            if (shortUser.name)
                mainText = shortUser.name;
            [labelMain_ setText:mainText];
            
            //set text
            NSMutableString *detailedText = [NSMutableString string];
            if (shortUser.age)
            {
                [detailedText appendFormat:@"%dM", [shortUser.age intValue]];
                if (shortUser.location)
                    [detailedText appendString:@", "];
            }
            if (shortUser.location)
                [detailedText appendString:shortUser.location];
            [labelDetails_ setText:detailedText];
            
            //set photo
            if (shortUser.photo.downloadUrl)
                [imageView_ reloadFromUrl:[NSURL URLWithString:shortUser.photo.downloadUrl]];
            else
                imageView_.image = nil;
        }
        else
        {
            //hide all
            [labelMain_ setHidden:YES];
            [labelDetails_ setHidden:YES];
            [imageView_ setHidden:YES];
        }
    }
}

+ (CGFloat)height
{
    return 50;
}

- (void)dealloc
{
    [shortUser release];
    [super dealloc];
}

@end
