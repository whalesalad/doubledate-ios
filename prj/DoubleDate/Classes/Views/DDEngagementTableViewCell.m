//
//  DDEngagementTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDEngagementTableViewCell.h"
#import "DDEngagement.h"
#import "DDPhotoView.h"
#import "DDTools.h"
#import "DDShortUser.h"
#import "DDUser.h"

@implementation DDEngagementTableViewCell

@synthesize engagement;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        labelTime_ = [[UILabel alloc] initWithFrame:CGRectZero];
        labelTime_.font = [UIFont boldSystemFontOfSize:13];
        labelTime_.textColor = [UIColor lightGrayColor];
        labelTime_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:labelTime_];
        
        labelUser_ = [[UILabel alloc] initWithFrame:CGRectZero];
        labelUser_.font = [UIFont boldSystemFontOfSize:16];
        labelUser_.textColor = [UIColor whiteColor];
        labelUser_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:labelUser_];
        
        labelWing_ = [[UILabel alloc] initWithFrame:CGRectZero];
        labelWing_.font = [UIFont boldSystemFontOfSize:16];
        labelWing_.textColor = [UIColor whiteColor];
        labelWing_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:labelWing_];
        
        imageViewGenderUser_ = [[UIImageView alloc] init];
        [self.contentView addSubview:imageViewGenderUser_];
        
        imageViewGenderWing_ = [[UIImageView alloc] init];
        [self.contentView addSubview:imageViewGenderWing_];
        
        photoUser_ = [[DDPhotoView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:photoUser_];
        
        photoWing_ = [[DDPhotoView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:photoWing_];
        
        self.backgroundView = [[[UIImageView alloc] initWithImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"incoming-message-row-bg.png"]]] autorelease];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    photoUser_.frame = CGRectMake(5, 5, 70, 70);
    photoWing_.frame = CGRectMake(75, 5, 70, 70);
    
    [labelUser_ sizeToFit];
    [labelWing_ sizeToFit];
    
    labelTime_.frame = CGRectMake(150, 14, 120, 13);
    labelUser_.frame = CGRectMake(150, 28, MIN(120, labelUser_.frame.size.width), 20);
    labelWing_.frame = CGRectMake(150, 48, MIN(120, labelWing_.frame.size.width), 20);
    
    imageViewGenderUser_.frame = CGRectMake(0, 0, imageViewGenderUser_.image.size.width, imageViewGenderUser_.image.size.height);
    imageViewGenderUser_.center = CGPointMake(labelUser_.frame.origin.x+labelUser_.frame.size.width+5+imageViewGenderUser_.image.size.width/2, labelUser_.center.y);
    imageViewGenderWing_.frame = CGRectMake(0, 0, imageViewGenderWing_.image.size.width, imageViewGenderWing_.image.size.height);
    imageViewGenderWing_.center = CGPointMake(labelWing_.frame.origin.x+labelWing_.frame.size.width+5+imageViewGenderWing_.image.size.width/2, labelWing_.center.y);
}

- (void)setEngagement:(DDEngagement *)v
{
    //check for the same instance
    if (v != engagement)
    {
        //update value
        [engagement release];
        engagement = [v retain];
        
        //check friend
        if (engagement)
        {
            //apply text
            labelTime_.text = engagement.createdAtAgo;
            labelUser_.text = [engagement.user.firstName uppercaseString];
            labelWing_.text = [engagement.wing.firstName uppercaseString];
            
            //apply genders
            imageViewGenderUser_.image = [UIImage imageNamed:[engagement.user.gender isEqualToString:DDUserGenderFemale]?@"female-indicator-small.png":@"male-indicator-small.png"];
            imageViewGenderWing_.image = [UIImage imageNamed:[engagement.wing.gender isEqualToString:DDUserGenderFemale]?@"female-indicator-small.png":@"male-indicator-small.png"];
            
            //apply photos
            [photoUser_ applyImage:engagement.user.photo];
            [photoWing_ applyImage:engagement.wing.photo];
        }
        else
        {
            labelTime_.text = nil;
            labelUser_.text = nil;
            labelWing_.text = nil;
            imageViewGenderUser_.image = nil;
            imageViewGenderWing_.image = nil;
            [photoUser_ applyImage:nil];
            [photoWing_ applyImage:nil];
        }
    }
}

+ (CGFloat)height
{
    return 80;
}

- (void)dealloc
{
    [engagement release];
    [labelTime_ release];
    [labelUser_ release];
    [labelWing_ release];
    [imageViewGenderUser_ release];
    [imageViewGenderWing_ release];
    [photoUser_ release];
    [photoWing_ release];
    [super dealloc];
}

@end
