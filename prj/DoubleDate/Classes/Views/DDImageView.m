//
//  DDImageView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
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
    //unset image
    self.image = nil;
    
    //check url
    if (url)
    {
        //show loading
        [activityIndicatorView_ startAnimating];
        
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

- (void)applyBorderStyling
{
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = 6.0f;
    
    self.layer.shadowOpacity = 0.3f;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 1);

    // create new layer for image with tighter border radius.
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = self.bounds;
    imageLayer.contents = (id) self.image.CGImage;
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = self.layer.cornerRadius + 1;
    
    // insert modified image
    [self.layer insertSublayer:imageLayer atIndex:0];
    
    // remove the old image
    [self setImage:nil];
    
    // Inner white border
    CALayer *innerGlowLayer = [CALayer layer];
    innerGlowLayer.frame = CGRectInset(self.bounds, 1, 1);
    innerGlowLayer.cornerRadius = 5;
    innerGlowLayer.borderWidth = 1;
    innerGlowLayer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.1f].CGColor;

    [self.layer insertSublayer:innerGlowLayer atIndex:1];    
}

- (void)dealloc
{
    [activityIndicatorView_ release];
    [super dealloc];
}

@end
