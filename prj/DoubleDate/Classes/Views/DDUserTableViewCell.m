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
#import "DDPhotoView.h"
#import "DDTools.h"
#import "DDUser.h"
#import <QuartzCore/QuartzCore.h>

@implementation DDUserTableViewCell

@synthesize type;

@synthesize shortUser;

- (UIColor*)inverseColor:(UIColor*)color
{
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a])
        color = [UIColor colorWithRed:1.0f-r green:1.0f-g blue:1.0f-b alpha:a];
    return color;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        labelMain_ = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        labelMain_.font = [UIFont boldSystemFontOfSize:16];
        labelMain_.textColor = [UIColor whiteColor];
        labelMain_.highlightedTextColor = [self inverseColor:labelMain_.textColor];
        labelMain_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:labelMain_];
        
        labelDetails_ = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        labelDetails_.font = [UIFont systemFontOfSize:14];
        labelDetails_.textColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1];
        labelDetails_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:labelDetails_];
        
        imageViewGender_ = [[[UIImageView alloc] init] autorelease];
        [self.contentView addSubview:imageViewGender_];
        
        imageView_ = [[[DDPhotoView alloc] initWithFrame:CGRectZero] autorelease];
        [self.contentView addSubview:imageView_];
        
        self.backgroundView = [[[UIImageView alloc] initWithImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"incoming-message-row-bg.png"]]] autorelease];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [imageView_ setFrame:CGRectMake(5, 5, 70, 70)];
    
    [labelMain_ sizeToFit];
    
    if (self.type == DDUserTableViewCellTypeWings)
    {
        [labelMain_ setFrame:CGRectMake(80, 10, MIN(180, labelMain_.frame.size.width), 32)];
        [labelDetails_ setFrame:CGRectMake(80, 42, 200, 18)];
    }
    else if (self.type == DDUserTableViewCellTypeInvitations)
    {
        [labelMain_ setFrame:CGRectMake(80, 10, MIN(140, labelMain_.frame.size.width), 32)];
        [labelDetails_ setFrame:CGRectMake(80, 42, 160, 18)];
    }
    else if (self.type == DDUserTableViewCellTypeFacebook)
    {
        [labelMain_ setFrame:CGRectMake(80, 10, MIN(160, labelMain_.frame.size.width), 32)];
        [labelDetails_ setFrame:CGRectMake(80, 42, 180, 18)];
    }
    
    imageViewGender_.frame = CGRectMake(0, 0, imageViewGender_.image.size.width, imageViewGender_.image.size.height);
    imageViewGender_.center = CGPointMake(labelMain_.frame.origin.x+labelMain_.frame.size.width+5+imageViewGender_.image.size.width/2, labelMain_.center.y);
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
                [detailedText appendFormat:@"%d%@", [shortUser.age intValue], [shortUser.gender isEqualToString:DDUserGenderFemale]?@"F":@"M"];
                if (shortUser.location)
                    [detailedText appendString:@", "];
            }
            if (shortUser.location)
                [detailedText appendString:shortUser.location];
            [labelDetails_ setText:detailedText];
            
            //set photo
            [imageView_ applyImage:shortUser.photo];
            
            //set gender
            imageViewGender_.image = [UIImage imageNamed:[shortUser.gender isEqualToString:DDUserGenderFemale]?@"female-indicator-small.png":@"male-indicator-small.png"];
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
    return 80;
}

- (void)dealloc
{
    [shortUser release];
    [super dealloc];
}

@end
