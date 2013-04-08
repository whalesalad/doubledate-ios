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
#import <QuartzCore/QuartzCore.h>

@interface DDImageEditDialogView ()<UIGestureRecognizerDelegate>

@property(nonatomic, retain) UIView *cropView;
@property(nonatomic, retain) DDImageView *imageView;
@property(nonatomic, assign) CGPoint startOffset;
@property(nonatomic, assign) CGPoint currentOffset;
@property(nonatomic, assign) CGFloat lastScale;
@property(nonatomic, assign) CGFloat currentScale;

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
@synthesize startOffset;
@synthesize currentOffset;
@synthesize lastScale;
@synthesize currentScale;

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
        
        //save current offset
        currentScale = 1;
    }
    return self;
}

- (void)move:(UIPanGestureRecognizer*)sender
{
    //save initial offset
    if([sender state] == UIGestureRecognizerStateBegan)
        self.startOffset = self.currentOffset;
    
    //add point
    CGPoint translatedPoint = [sender translationInView:self];
    
    //set current offset
    self.currentOffset = CGPointMake(self.startOffset.x + translatedPoint.x, self.startOffset.y + translatedPoint.y);
}

- (void)scale:(UIPinchGestureRecognizer*)sender
{
    //save initial scale
    if([sender state] == UIGestureRecognizerStateBegan)
        self.lastScale = 1;
    
    //set current scale
    self.currentScale *= 1.0 - (self.lastScale - [sender scale]);
    
    //update value
    self.lastScale = [sender scale];
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
    panRecognizer.delegate = self;
    [self.cropView addGestureRecognizer:panRecognizer];
    
    //add gesture recognizer
    UIPinchGestureRecognizer *pinchRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)] autorelease];
    pinchRecognizer.delegate = self;
    [self.cropView addGestureRecognizer:pinchRecognizer];
    
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
            
            //update frame
            CGPoint imageViewCenter = self.imageView.center;
            self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.width * initialImage_.size.height / initialImage_.size.width);
            self.imageView.center = imageViewCenter;
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

- (BOOL)isImageViewInsideCrop
{
    //save offset
    CGPoint offset = CGPointMake(self.cropView.bounds.size.width / 2 - self.imageView.center.x, self.cropView.bounds.size.height / 2 - self.imageView.center.y);

    //save rect
    CGFloat newWidth = self.imageView.frame.size.width * self.currentScale;
    CGFloat newHeight = self.imageView.frame.size.height * self.currentScale;
    CGRect imageViewRect = CGRectMake(self.imageView.center.x - newWidth / 2 - offset.x * self.currentScale, self.imageView.center.y - newHeight / 2 - offset.y * self.currentScale, newWidth, newHeight);
    
    //check intersection
    return CGRectEqualToRect(CGRectIntersection(imageViewRect, self.cropView.bounds), self.cropView.bounds);
}

- (BOOL)applyChangeOnPoint:(CGPoint)offset
{
    //save image view center
    CGPoint imageViewCenter = self.imageView.center;
    
    //apply in one direction
    self.imageView.center = CGPointMake(self.cropView.bounds.size.width/2 + offset.x, self.cropView.bounds.size.height/2 + offset.y);
    
    //check if the image view is inside the crop rect
    if ([self isImageViewInsideCrop])
        return YES;
    
    //restore center
    self.imageView.center = imageViewCenter;
    
    return NO;
}

- (void)setCurrentOffset:(CGPoint)v
{
    //check if image exist
    if (initialImage_)
    {
        //check difference
        CGPoint initialDiff = CGPointMake(v.x - currentOffset.x, v.y - currentOffset.y);
        
        //number of steps
        NSInteger stepsCount = 10;
        
        //apply offset
        if ([self applyChangeOnPoint:CGPointMake(currentOffset.x + initialDiff.x, currentOffset.y)])
            currentOffset = CGPointMake(currentOffset.x + initialDiff.x, currentOffset.y);
        else
        {
            for (int i = 0; i < stepsCount; i++)
            {
                CGPoint diff = CGPointMake(initialDiff.x * i / 10, 0);
                if ([self applyChangeOnPoint:CGPointMake(currentOffset.x + diff.x, currentOffset.y + diff.y)])
                    break;
            }
        }
        
        //apply offset
        if ([self applyChangeOnPoint:CGPointMake(currentOffset.x, currentOffset.y + initialDiff.y)])
            currentOffset = CGPointMake(currentOffset.x, currentOffset.y + initialDiff.y);
        else
        {
            for (int i = 0; i < stepsCount; i++)
            {
                CGPoint diff = CGPointMake(0, initialDiff.y * i / 10);
                if ([self applyChangeOnPoint:CGPointMake(currentOffset.x + diff.x, currentOffset.y + diff.y)])
                    break;
            }
        }
    }
}

- (void)setCurrentScale:(CGFloat)v
{
    //check if image exist
    if (initialImage_)
    {
        //save old value
        CGFloat oldValue = currentScale;
        
        //set limits
        v = MIN(MAX(v, 1), 2);
        
        //update value
        currentScale = v;
        
        //check for new frame adn restore it
        if ([self isImageViewInsideCrop])
            self.imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, currentScale, currentScale);
        else
            currentScale = oldValue;
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

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
