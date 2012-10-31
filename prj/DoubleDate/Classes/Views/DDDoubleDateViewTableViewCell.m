//
//  DDDoubleDateViewTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDateViewTableViewCell.h"
#import "DDImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "DDDoubleDate.h"
#import "DDImage.h"
#import "DDShortUser.h"

@implementation DDDoubleDateViewTableViewCell

@synthesize doubleDate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        //add arrow
        self.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dd-tablecell-detail-arrow.png"]] autorelease];
        
        //add background
        imageViewPhotosBackground_ = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doublephoto-container.png"]] autorelease];
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
        [self.contentView addSubview:labelTitle_];
        
        //add location image view
        UIImageView *imageViewLocation = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location-marker.png"]] autorelease];
        imageViewLocation.center = CGPointMake(106, 40);
        imageViewLocation.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
        [self.contentView addSubview:imageViewLocation];
        
        //add location
        labelLocation_ = [[UILabel alloc] initWithFrame:CGRectZero];
        labelLocation_.textColor = [UIColor lightGrayColor];
        labelLocation_.contentMode = UIViewContentModeLeft;
        labelLocation_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:labelLocation_];
        
        //add distance
        labelDistance_ = [[UILabel alloc] initWithFrame:CGRectZero];
        labelDistance_.textColor = [UIColor lightGrayColor];
        labelDistance_.contentMode = UIViewContentModeLeft;
        labelDistance_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:labelDistance_];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    imageViewPhotosBackground_.center = CGPointMake(48, self.contentView.frame.size.height/2-1);
    labelTitle_.frame = CGRectMake(100, 4, 190, 26);
    labelLocation_.frame = CGRectMake(114, 29, labelLocation_.frame.size.width, labelLocation_.frame.size.height);
    labelDistance_.frame = CGRectMake(labelLocation_.frame.origin.x+labelLocation_.frame.size.width+10, labelLocation_.frame.origin.y, labelDistance_.frame.size.width, labelLocation_.frame.size.height);
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
    labelLocation_.text = [[v locationId] stringValue];
    [labelLocation_ sizeToFit];
    
    //apply distance
    labelDistance_.text = @"3 mi";
    [labelDistance_ sizeToFit];
}

- (void)dealloc
{
    [imageViewUser_ release];
    [imageViewWing_ release];
    [labelTitle_ release];
    [labelLocation_ release];
    [labelDistance_ release];
    [doubleDate release];
    [super dealloc];
}

@end
