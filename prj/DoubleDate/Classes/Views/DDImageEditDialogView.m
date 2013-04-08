//
//  DDImageEditDialogView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDImageEditDialogView.h"
#import "DDImage.h"
#import "DDImageView.h"

@interface DDImageEditDialogView ()

@property(nonatomic, retain) UIView *cropView;
@property(nonatomic, retain) DDImageView *imageView;
@property(nonatomic, assign) CGPoint startOffset;
@property(nonatomic, assign) CGPoint currentOffset;

@end

@implementation DDImageEditDialogView
{
    UIImageView *baseImageView_;
    UIView *parentView_;
    DDImage *image_;
    UIImage *initialImage_;
    BOOL shown_;
}

@synthesize cropView;
@synthesize imageView;
@synthesize currentOffset;

- (id)initWithImage:(DDImage*)image inImageView:(UIImageView*)referenceImageView ofView:(UIView*)view
{
    if ((self = [super initWithFrame:view.bounds]))
    {
        //save reference image view
        baseImageView_ = [referenceImageView retain];
        
        //save parent window
        parentView_ = [view retain];
        
        //save image
        image_ = [image retain];
    }
    return self;
}

- (void)move:(UIPanGestureRecognizer*)sender
{
    //save initial offset
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan)
        self.startOffset = self.currentOffset;
    
    //add point
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self];
    
    //set current offset
    self.currentOffset = CGPointMake(self.startOffset.x + translatedPoint.x, self.startOffset.y + translatedPoint.y);
}

- (void)show
{
    //check if already shown
    if (shown_)
        return;
    
    //set shown flag
    shown_ = YES;
    
    //set background color
    self.backgroundColor = [UIColor blackColor];
    
    //set frame
    self.frame = [parentView_ bounds];
    
    //set autoresizing mask
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    //add self to parent
    [parentView_ addSubview:self];
    
    //add crop view
    self.cropView = [[[UIView alloc] initWithFrame:[baseImageView_ convertRect:baseImageView_.frame toView:parentView_]] autorelease];
    self.cropView.backgroundColor = [UIColor clearColor];
    self.cropView.clipsToBounds = YES;
    [parentView_ addSubview:self.cropView];
    
    //add gesture recognizers
    UIPanGestureRecognizer *panRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)] autorelease];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self.cropView addGestureRecognizer:panRecognizer];
    
    //add image view
    self.imageView = [[[DDImageView alloc] initWithImage:baseImageView_.image] autorelease];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.frame = self.cropView.bounds;
    [self.imageView setImageWithURL:[NSURL URLWithString:image_.originalUrl] placeholderImage:baseImageView_.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (!error)
        {
            //save initial image
            [initialImage_ release];
            initialImage_ = [image retain];
        }
    }];
    [self.cropView addSubview:self.imageView];
}

- (void)dismiss
{
    //check if already hidden
    if (!shown_)
        return;
    
    //unset shown flag
    shown_ = NO;
}

- (void)setCurrentOffset:(CGPoint)v
{
    //check if image exist
    if (initialImage_)
    {
        //save difference in real values
        CGFloat dy = initialImage_.size.height - (baseImageView_.image.size.height / baseImageView_.image.size.width * initialImage_.size.width);
        
        //save scale
        CGFloat scale = self.imageView.frame.size.width / initialImage_.size.width;
        
        //save scaled offset
        CGFloat scaledDy = dy / scale;
                
        //check offset
        if (v.y < 0 && (-v.y) < scaledDy)
        {
            //update center
            self.imageView.center = CGPointMake(self.cropView.bounds.size.width/2, self.cropView.bounds.size.height/2 + v.y);
            
            //update offset
            currentOffset = v;
        }
    }
}

- (void)dealloc
{
    [baseImageView_ release];
    [parentView_ release];
    [image_ release];
    [initialImage_ release];
    [cropView release];
    [imageView release];
    [super dealloc];
}

@end
