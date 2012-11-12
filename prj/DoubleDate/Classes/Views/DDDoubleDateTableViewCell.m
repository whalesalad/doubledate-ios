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

+ (CGFloat)height
{
    return 60;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        //add background
        imageViewBackground_ = [[UIImageView alloc] initWithImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"dd-tablecell-background.png"]]];
        [self addSubview:imageViewBackground_];
        [self bringSubviewToFront:self.contentView];
        
        //add background
        imageViewPhotosBackground_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doublephoto-container.png"]];
        [self.contentView addSubview:imageViewPhotosBackground_];
        
        {
            //add user image
            imageViewUser_ = [[DDImageView alloc] initWithImage:nil];
            imageViewUser_.frame = CGRectMake(0, 0, 38, 38);
            imageViewUser_.center = CGPointMake(21, imageViewPhotosBackground_.frame.size.height/2);
            UIImage *maskingImage = [UIImage imageNamed:@"doublephoto-left-image-mask.png"];
            CALayer *maskingLayer = [CALayer layer];
            maskingLayer.frame = CGRectMake(0, 0, maskingImage.size.width, maskingImage.size.height);
            [maskingLayer setContents:(id)[maskingImage CGImage]];
            [imageViewUser_.layer setMask:maskingLayer];
            imageViewUser_.layer.masksToBounds = YES;
            [imageViewPhotosBackground_ addSubview:imageViewUser_];
            
            //add gloss
            UIImageView *gloss = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doublephoto-gloss.png"]] autorelease];
            [imageViewUser_ addSubview:gloss];
        }
        
        {
            //add user image
            imageViewWing_ = [[DDImageView alloc] initWithImage:nil];
            imageViewWing_.frame = CGRectMake(0, 0, 40, 38);
            imageViewWing_.center = CGPointMake(61, imageViewPhotosBackground_.frame.size.height/2);
            UIImage *maskingImage = [UIImage imageNamed:@"doublephoto-right-image-mask.png"];
            CALayer *maskingLayer = [CALayer layer];
            maskingLayer.frame = CGRectMake(0, 0, maskingImage.size.width, maskingImage.size.height);
            [maskingLayer setContents:(id)[maskingImage CGImage]];
            [imageViewWing_.layer setMask:maskingLayer];
            imageViewWing_.layer.masksToBounds = YES;
            [imageViewPhotosBackground_ addSubview:imageViewWing_];
            
            //add gloss
            UIImageView *gloss = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doublephoto-gloss.png"]] autorelease];
            [imageViewWing_ addSubview:gloss];
        }
        
        //add title
        labelTitle_ = [[UILabel alloc] initWithFrame:CGRectZero];
        labelTitle_.textColor = [UIColor whiteColor];
        labelTitle_.contentMode = UIViewContentModeLeft;
        labelTitle_.backgroundColor = [UIColor clearColor];
        labelTitle_.font = [DDTools avenirFontOfSize:14];
        [self.contentView addSubview:labelTitle_];
        
        //add location image view
        imageViewLocation_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dd-tablecell-location-icon.png"]];
        [self.contentView addSubview:imageViewLocation_];
        
        //add location
        labelLocation_ = [[UILabel alloc] initWithFrame:CGRectZero];
        labelLocation_.textColor = [UIColor lightGrayColor];
        labelLocation_.contentMode = UIViewContentModeLeft;
        labelLocation_.backgroundColor = [UIColor clearColor];
        labelLocation_.font = [DDTools avenirFontOfSize:14];
        [self.contentView addSubview:labelLocation_];
        
        //add distance
        labelDistance_ = [[UILabel alloc] initWithFrame:CGRectZero];
        labelDistance_.textColor = [UIColor lightGrayColor];
        labelDistance_.contentMode = UIViewContentModeLeft;
        labelDistance_.backgroundColor = [UIColor clearColor];
        labelDistance_.font = [DDTools avenirFontOfSize:14];
        [self.contentView addSubview:labelDistance_];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    imageViewBackground_.frame = CGRectMake(0, 0, self.frame.size.width, imageViewBackground_.image.size.height);
    imageViewBackground_.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    imageViewPhotosBackground_.center = CGPointMake(56, self.contentView.frame.size.height/2-1);
    imageViewLocation_.center = CGPointMake(110, 38);
    labelTitle_.frame = CGRectMake(105, 6, 190, 26);
    labelLocation_.frame = CGRectMake(120, 30, labelLocation_.frame.size.width, labelLocation_.frame.size.height);
    labelDistance_.frame = CGRectMake(labelLocation_.frame.origin.x+labelLocation_.frame.size.width+4, labelLocation_.frame.origin.y, labelDistance_.frame.size.width, labelLocation_.frame.size.height);
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
    [imageViewUser_ reloadFromUrl:[NSURL URLWithString:doubleDate.user.photo.downloadUrl]];
    [imageViewWing_ reloadFromUrl:[NSURL URLWithString:doubleDate.wing.photo.downloadUrl]];
    
    //apply text
    labelTitle_.text = [v title];
    
    //apply location
    labelLocation_.text = [[v location] name];
    [labelLocation_ sizeToFit];
    if (labelLocation_.frame.size.width > 120)
        labelLocation_.frame = CGRectMake(0, 0, 120, labelLocation_.frame.size.height);
    
    //apply distance
    labelDistance_.text = @"3 mi";
    [labelDistance_ sizeToFit];
}

- (void)dealloc
{
    [imageViewPhotosBackground_ release];
    [imageViewUser_ release];
    [imageViewWing_ release];
    [imageViewLocation_ release];
    [labelTitle_ release];
    [labelLocation_ release];
    [labelDistance_ release];
    [doubleDate release];
    [super dealloc];
}

@end
