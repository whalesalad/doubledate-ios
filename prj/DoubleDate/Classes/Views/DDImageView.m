//
//  DDImageView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDImageView.h"

@implementation DDImageView

- (void)selfInit
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
        [self selfInit];
        self.frame = self.frame;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self selfInit];
        self.frame = self.frame;
    }
    return self;
}

- (void)reloadFromUrl:(NSURL*)url
{
    //remove connection
    [connection_ cancel];
    [connection_ release];
    connection_ = nil;
    
    //start connection
    if (url)
    {
        //show loading
        [activityIndicatorView_ startAnimating];
        
        //start request
        NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];
        connection_ = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [connection_ start];
    }
}

- (void)setFrame:(CGRect)v
{
    [super setFrame:v];
    [activityIndicatorView_ setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    self.image = [UIImage imageWithData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //stop loading
    [activityIndicatorView_ stopAnimating];
    
    //release connection
    [connection_ release];
    connection_ = nil;
}

- (void)dealloc
{
    [connection_ release];
    [activityIndicatorView_ release];
    [super dealloc];
}

@end
