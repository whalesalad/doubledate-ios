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
    self.contentMode = UIViewContentModeScaleAspectFill;
    
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

- (void)dealloc
{
    [activityIndicatorView_ release];
    [super dealloc];
}

@end

@implementation DDStyledImageView
{
    DDImageView *imageView_;
}

@synthesize image;

- (void)initSelf
{
    CGFloat baseCornerRadius = 6.0f;
    
    self.backgroundColor = [UIColor clearColor];
    
    imageView_ = [[DDImageView alloc] initWithFrame:self.bounds];
    imageView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView_.contentMode = UIViewContentModeScaleAspectFill;
    imageView_.layer.cornerRadius = baseCornerRadius + 1;
    imageView_.backgroundColor = [UIColor darkGrayColor];
    imageView_.clipsToBounds = YES;
    [self addSubview:imageView_];
    
    UIView *innerGlow = [[[UIView alloc] initWithFrame:CGRectInset(self.bounds, 1, 1)] autorelease];
    innerGlow.backgroundColor = [UIColor clearColor];
    innerGlow.layer.cornerRadius = baseCornerRadius - 1;
    innerGlow.layer.borderWidth = 1;
    innerGlow.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.1f].CGColor;
    [self addSubview:innerGlow];

    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = baseCornerRadius;

    self.layer.shadowRadius = 2.0f;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowOpacity = 0.3f;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initSelf];
    }
    return self;
}

- (id)initWithImage:(UIImage*)i
{
    if ((self = [super initWithFrame:CGRectMake(0, 0, i.size.width, i.size.height)]))
    {
        [self initSelf];
        self.image = i;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self initSelf];
    }
    return self;
}

- (void)setImage:(UIImage *)i
{
    if (self.image != i)
    {
        [imageView_ cancelCurrentImageLoad];
        [imageView_ setImage:i];
    }
}

- (UIImage*)image
{
    return imageView_.image;
}

- (void)reloadFromUrl:(NSURL*)url
{
    [imageView_ reloadFromUrl:url];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)addImageOverlay:(UIView *)view
{
    [imageView_ addSubview:view];
}

- (UIImageView*)internalImageView
{
    return imageView_;
}

- (void)dealloc
{
    [imageView_ release];
    [super dealloc];
}

@end
