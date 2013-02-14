//
//  DDImageView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDImageView.h"
#import <QuartzCore/QuartzCore.h>

NSString *const DDImageViewUpdateNotification = @"DDImageViewUpdateNotification";

@implementation DDImageView

- (void)initSelf
{
    if (!activityIndicatorView_)
    {
        activityIndicatorView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicatorView_.hidesWhenStopped = YES;
        [self addSubview:activityIndicatorView_];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initSelf];
        self.frame = self.frame;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self initSelf];
        self.frame = self.frame;
    }
    return self;
}

- (void)reloadFromUrl:(NSURL*)url
{
    //show loading
    [activityIndicatorView_ startAnimating];
    
    //unset image
    self.image = nil;
    
    //load from url
    [self setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
        //stop animating
        [activityIndicatorView_ stopAnimating];
        
        //apply new image
        self.image = image;
        
        //notify about change
        [[NSNotificationCenter defaultCenter] postNotificationName:DDImageViewUpdateNotification object:self];
    }];
}

- (void)applyMask:(UIImage*)mask
{
    CALayer *maskingLayer = [CALayer layer];
    maskingLayer.frame = CGRectMake(0, 0, mask.size.width, mask.size.height);
    [maskingLayer setContents:(id)[mask CGImage]];
    [self.layer setMask:maskingLayer];
    self.layer.masksToBounds = YES;
}

- (void)setFrame:(CGRect)v
{
    [super setFrame:v];
    [activityIndicatorView_ setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
}

- (void)setImage:(UIImage *)i
{
    //set image
    [super setImage:i];

    //remove connection
    [self cancelCurrentImageLoad];
}

- (void)dealloc
{
    [activityIndicatorView_ release];
    [super dealloc];
}

@end
