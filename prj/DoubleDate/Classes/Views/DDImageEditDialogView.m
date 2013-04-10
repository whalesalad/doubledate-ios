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
#import "DDAppDelegate.h"
#import "DDBarButtonItem.h"
#import "DDTools.h"
#import <QuartzCore/QuartzCore.h>

@interface DDImageEditDialogView ()<UIGestureRecognizerDelegate>

@property(nonatomic, retain) UIView *topLeftCornerView;
@property(nonatomic, retain) UIView *topRightCornerView;
@property(nonatomic, retain) UIView *bottomLeftCornerView;
@property(nonatomic, retain) UIView *bottomRightCornerView;
@property(nonatomic, retain) UIView *bottomView;
@property(nonatomic, retain) UIView *dimView;
@property(nonatomic, retain) UINavigationBar *navigationBar;
@property(nonatomic, retain) UIView *cropView;
@property(nonatomic, retain) UIImageView *imageView;
@property(nonatomic, assign) CGPoint startOffset;
@property(nonatomic, assign) CGPoint currentOffset;
@property(nonatomic, assign) CGFloat lastScale;
@property(nonatomic, assign) CGFloat currentScale;

@end

@implementation DDImageEditDialogView
{
    UIImageView *baseImageView_;
    DDImage *ddImage_;
    UIImage *uiImage_;
    UIImage *initialImage_;
    BOOL shown_;
}

@synthesize delegate;

@synthesize topLeftCornerView;
@synthesize topRightCornerView;
@synthesize bottomLeftCornerView;
@synthesize bottomRightCornerView;
@synthesize bottomView;
@synthesize dimView;
@synthesize navigationBar;
@synthesize cropView;
@synthesize imageView;
@synthesize startOffset;
@synthesize currentOffset;
@synthesize lastScale;
@synthesize currentScale;

@synthesize ddImage = ddImage_;
@synthesize uiImage = uiImage_;

- (id)initWithDDImage:(DDImage*)image inImageView:(UIImageView*)referenceImageView
{
    if ((self = [super init]))
    {
        //save reference image view
        baseImageView_ = [referenceImageView retain];
        
        //save image
        ddImage_ = [image retain];
        
        //save current offset
        currentScale = 1;
    }
    return self;
}

- (id)initWithUIImage:(UIImage*)image inImageView:(UIImageView*)referenceImageView
{
    if ((self = [super init]))
    {
        //save reference image view
        baseImageView_ = [referenceImageView retain];
        
        //save image
        uiImage_ = [image retain];
        
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

- (void)moveImageViewToFitTheCrop
{
    //check if we need to animate
    if (![self isImageViewInsideCrop])
    {
        //save intersection rect
        CGRect intersection = CGRectIntersection(self.cropView.frame, self.imageView.frame);

        //save differences
        CGFloat dx = 0;
        if (CGRectGetMinX(intersection) > CGRectGetMinX(self.cropView.frame))
            dx = CGRectGetMinX(intersection) - CGRectGetMinX(self.cropView.frame);
        else if (CGRectGetMaxX(intersection) < CGRectGetMaxX(self.cropView.frame))
            dx = CGRectGetMaxX(intersection) - CGRectGetMaxX(self.cropView.frame);
        CGFloat dy = 0;
        if (CGRectGetMinY(intersection) > CGRectGetMinY(self.cropView.frame))
            dy = CGRectGetMinY(intersection) - CGRectGetMinY(self.cropView.frame);
        else if (CGRectGetMaxY(intersection) < CGRectGetMaxY(self.cropView.frame))
            dy = CGRectGetMaxY(intersection) - CGRectGetMaxY(self.cropView.frame);
        
        //move
        CGPoint newCenter = CGPointMake(self.imageView.center.x - dx, self.imageView.center.y - dy);
        [UIView animateWithDuration:0.2f animations:^{
            self.imageView.center = newCenter;
        } completion:^(BOOL finished) {
            self.imageView.center = newCenter;
        }];
        
        //set current offset
        currentOffset = CGPointMake(newCenter.x - self.cropView.bounds.size.width / 2, newCenter.y - self.cropView.bounds.size.height / 2);
    }
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
    
    //apply final animation
    if ([sender state] == UIGestureRecognizerStateEnded)
        [self moveImageViewToFitTheCrop];
}

- (CGPoint)offsetForView:(UIView*)view
{
    CGFloat offset = 4;
    if (view == self.topLeftCornerView)
        return CGPointMake(offset, offset);
    else if (view == self.topRightCornerView)
        return CGPointMake(-offset, offset);
    if (view == self.bottomLeftCornerView)
        return CGPointMake(offset, -offset);
    else if (view == self.bottomRightCornerView)
        return CGPointMake(-offset, -offset);
    return CGPointZero;
}

- (CGFloat)cornerPadding
{
    return 6;
}

- (CGFloat)cornerAnimationDuration
{
    return 0.4;
}

- (CGFloat)cornerAnimationDelay
{
    return 0;
}

- (void)animateCornersOut:(UIView*)view
{
    [self performSelector:@selector(animateCornersIn:) withObject:view afterDelay:[self cornerAnimationDelay] + [self cornerAnimationDuration]];
    [UIView animateWithDuration:[self cornerAnimationDuration] animations:^{
        view.center = CGPointMake(view.center.x - [self offsetForView:view].x, view.center.y - [self offsetForView:view].y);
    } completion:^(BOOL finished) {
    }];
}

- (void)animateCornersIn:(UIView*)view
{
    [self performSelector:@selector(animateCornersOut:) withObject:view afterDelay:[self cornerAnimationDelay] + [self cornerAnimationDuration]];
    [UIView animateWithDuration:[self cornerAnimationDuration] animations:^{
        view.center = CGPointMake(view.center.x + [self offsetForView:view].x, view.center.y + [self offsetForView:view].y);
    } completion:^(BOOL finished) {
    }];
}

- (void)show
{
    //save window
    UIWindow *window = [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] window];
    
    //show in window
    [self showInView:window];
}

- (void)showInView:(UIView*)window
{
    //check if already shown
    if (shown_)
        return;
    
    //set shown flag
    shown_ = YES;
    
    //set frame
    self.frame = [window bounds];
    
    //set autoresizing mask
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    //add self to parent
    [window addSubview:self];
    
    //set background color
    self.backgroundColor = [UIColor clearColor];
    
    {
        //add dim view
        self.dimView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        self.dimView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
        self.dimView.alpha = 0;
        [self addSubview:self.dimView];
    }
    
    if ([window isKindOfClass:[UIWindow class]])
    {
        //add fake navigation bar
        self.navigationBar = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.window.frame.size.width, 44)] autorelease];
        self.navigationBar.alpha = 0;
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav-background.png"] forBarMetrics:UIBarMetricsDefault];
        [self addSubview:self.navigationBar];
        [self.navigationBar pushNavigationItem:[[[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Resize & Position", nil)] autorelease] animated:NO];
    }
    
    {
        //add crop view
        self.cropView = [[[UIView alloc] initWithFrame:[baseImageView_ convertRect:baseImageView_.frame toView:window]] autorelease];
        self.cropView.backgroundColor = [UIColor clearColor];
        self.cropView.alpha = 0;
        self.cropView.clipsToBounds = YES;
        [self addSubview:self.cropView];
        
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
        self.imageView = [[[DDImageView alloc] initWithImage:nil] autorelease];
        self.imageView.contentMode = baseImageView_.contentMode;
        self.imageView.frame = self.cropView.bounds;
        
        if (ddImage_)
        {
            [self.imageView setImageWithURL:[NSURL URLWithString:ddImage_.originalUrl] placeholderImage:baseImageView_.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
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
        }
        else if (uiImage_)
        {
            //set image
            self.imageView.image = uiImage_;
            
            //save initial image
            [initialImage_ release];
            initialImage_ = [uiImage_ retain];
            
            //update frame
            CGPoint imageViewCenter = self.imageView.center;
            self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.width * initialImage_.size.height / initialImage_.size.width);
            self.imageView.center = imageViewCenter;
        }
        [self.cropView addSubview:self.imageView];
        
        //apply masking layer to the whole crop view
        UIImage *maskingImage = [UIImage imageNamed:@"bg-me-photo-mask.png"];
        CALayer *maskingLayer = [CALayer layer];
        maskingLayer.frame = CGRectMake(0, 0, maskingImage.size.width, maskingImage.size.height);
        [maskingLayer setContents:(id)[maskingImage CGImage]];
        [self.cropView.layer setMask:maskingLayer];
        self.cropView.layer.masksToBounds = YES;
        
        //add corners
        {
            {
                //add image view
                self.topLeftCornerView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upper-left.png"]] autorelease];
                self.topLeftCornerView.center = CGPointMake(self.topLeftCornerView.center.x + self.cornerPadding, self.topLeftCornerView.center.y + self.cornerPadding);
                self.topLeftCornerView.alpha = 0;
                [self.cropView.superview addSubview:self.topLeftCornerView];
                
                //add animation
                [self animateCornersIn:self.topLeftCornerView];
            }
            
            {
                //add image view
                self.topRightCornerView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upper-right.png"]] autorelease];
                self.topRightCornerView.center = CGPointMake(self.topRightCornerView.center.x + self.cropView.bounds.size.width - self.topRightCornerView.frame.size.width - self.cornerPadding, self.topRightCornerView.center.y + self.cornerPadding);
                self.topRightCornerView.alpha = 0;
                [self.cropView.superview addSubview:self.topRightCornerView];
                
                //add animation
                [self animateCornersIn:self.topRightCornerView];
            }
            
            {
                //add image view
                self.bottomLeftCornerView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lower-left.png"]] autorelease];
                self.bottomLeftCornerView.center = CGPointMake(self.bottomLeftCornerView.center.x + self.cornerPadding, self.bottomLeftCornerView.center.y + self.cropView.bounds.size.height - self.topRightCornerView.frame.size.height - self.cornerPadding);
                self.bottomLeftCornerView.alpha = 0;
                [self.cropView.superview addSubview:self.bottomLeftCornerView];
                
                //add animation
                [self animateCornersIn:self.bottomLeftCornerView];
            }
            
            {
                //add image view
                self.bottomRightCornerView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lower-right.png"]] autorelease];
                self.bottomRightCornerView.center = CGPointMake(self.bottomRightCornerView.center.x + self.cropView.bounds.size.width - self.bottomRightCornerView.frame.size.width - self.cornerPadding, self.bottomRightCornerView.center.y + self.cropView.bounds.size.height - self.bottomRightCornerView.frame.size.height - self.cornerPadding);
                self.bottomRightCornerView.alpha = 0;
                [self.cropView.superview addSubview:self.bottomRightCornerView];
                
                //add animation
                [self animateCornersIn:self.bottomRightCornerView];
            }
        }
    }
    
    {
        //add background
        UIImageView *background = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lower-button-bar-bg.png"]] autorelease];
        background.frame = CGRectMake(background.frame.origin.x, background.frame.origin.y, window.bounds.size.width, background.frame.size.height);
        
        //add bottom view
        self.bottomView = [[[UIView alloc] initWithFrame:CGRectMake(0, window.bounds.size.height, window.bounds.size.width, background.frame.size.height)] autorelease];
        [self.bottomView addSubview:background];
        [self addSubview:self.bottomView];
        
        //add button
        UIImage *cancelImage = [UIImage imageNamed:@"lower-button-gray.png"];
        UIButton *buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bottomView addSubview:buttonCancel];
        [buttonCancel addTarget:self action:@selector(cancelTouched:) forControlEvents:UIControlEventTouchUpInside];
        buttonCancel.frame = CGRectMake(0, 0, 100, cancelImage.size.height);
        [buttonCancel setBackgroundImage:[DDTools resizableImageFromImage:cancelImage] forState:UIControlStateNormal];
        buttonCancel.center = CGPointMake(60, self.bottomView.frame.size.height/2);
        [buttonCancel setTitle:NSLocalizedString(@"Cancel", @"Cancel button of crop image UI") forState:UIControlStateNormal];
        
        //add button
        UIImage *saveImage = [UIImage imageNamed:@"lower-button-blue.png"];
        UIButton *buttonSave = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bottomView addSubview:buttonSave];
        [buttonSave addTarget:self action:@selector(saveTouched:) forControlEvents:UIControlEventTouchUpInside];
        buttonSave.frame = CGRectMake(0, 0, 100, saveImage.size.height);
        [buttonSave setBackgroundImage:[DDTools resizableImageFromImage:saveImage] forState:UIControlStateNormal];
        buttonSave.center = CGPointMake(320-60, self.bottomView.frame.size.height/2);
        [buttonSave setTitle:NSLocalizedString(@"Save", @"Save button of crop image UI") forState:UIControlStateNormal];
    }
    
    //inform delegate
    [self.delegate imageEditDialogViewWillShow:self];
    
    //animate
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        self.dimView.alpha = 1;
        self.navigationBar.alpha = 1;
        self.cropView.alpha = 1;
        self.bottomView.center = CGPointMake(self.bottomView.center.x, self.bottomView.center.y - self.bottomView.frame.size.height);
        self.topLeftCornerView.alpha = 1;
        self.topRightCornerView.alpha = 1;
        self.bottomLeftCornerView.alpha = 1;
        self.bottomRightCornerView.alpha = 1;
    } completion:^(BOOL finished) {
        
        //inform delegate
        [self.delegate imageEditDialogViewDidShow:self];
    }];
}

- (void)dismiss
{
    //check if already hidden
    if (!shown_)
        return;
    
    //unset shown flag
    shown_ = NO;
    
    //disable user interaction
    self.userInteractionEnabled = NO;
    
    //cancel previous selectors
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    //inform delegate
    [self.delegate imageEditDialogViewWillHide:self];
    
    //animate
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        self.dimView.alpha = 0;
        self.navigationBar.alpha = 0;
        self.cropView.alpha = 0;
        self.bottomView.center = CGPointMake(self.bottomView.center.x, self.bottomView.center.y + self.bottomView.frame.size.height);
        self.topLeftCornerView.alpha = 0;
        self.topRightCornerView.alpha = 0;
        self.bottomLeftCornerView.alpha = 0;
        self.bottomRightCornerView.alpha = 0;
    } completion:^(BOOL finished) {
        
        //inform delegate
        [self.delegate imageEditDialogViewDidHide:self];
        
        //remove from superview
        [self removeFromSuperview];
    }];
}

- (BOOL)isImageViewInsideCrop
{
    return CGRectEqualToRect(CGRectIntersection(self.imageView.frame, self.cropView.bounds), self.cropView.bounds);
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
        NSInteger stepsCount = 20;
        
        //apply offset
        if ([self applyChangeOnPoint:CGPointMake(currentOffset.x + initialDiff.x, currentOffset.y)])
            currentOffset = CGPointMake(currentOffset.x + initialDiff.x, currentOffset.y);
        else
        {
            for (int i = 1; i < stepsCount; i++)
            {
                CGPoint diff = CGPointMake(initialDiff.x * i / stepsCount, 0);
                if ([self applyChangeOnPoint:CGPointMake(currentOffset.x + diff.x, currentOffset.y + diff.y)])
                {
                    currentOffset = CGPointMake(currentOffset.x + diff.x, currentOffset.y + diff.y);
                    break;
                }
            }
        }
        
        //apply offset
        if ([self applyChangeOnPoint:CGPointMake(currentOffset.x, currentOffset.y + initialDiff.y)])
            currentOffset = CGPointMake(currentOffset.x, currentOffset.y + initialDiff.y);
        else
        {
            for (int i = 1; i < stepsCount; i++)
            {
                CGPoint diff = CGPointMake(0, initialDiff.y * i / stepsCount);
                if ([self applyChangeOnPoint:CGPointMake(currentOffset.x + diff.x, currentOffset.y + diff.y)])
                {
                    currentOffset = CGPointMake(currentOffset.x + diff.x, currentOffset.y + diff.y);
                    break;
                }
            }
        }
    }
}

- (BOOL)applyChangeOnScale:(CGFloat)scale
{
    //save image view transform
    CGAffineTransform imageViewTransform = self.imageView.transform;
    
    //apply new transform
    self.imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    
    //check if the image view is inside the crop rect
    if ([self isImageViewInsideCrop])
        return YES;
    
    //restore center
    self.imageView.transform = imageViewTransform;
    
    return NO;
}

- (void)setCurrentScale:(CGFloat)v
{
    //check if image exist
    if (initialImage_)
    {
        //set limits
        currentScale = MIN(MAX(v, 1), 3);
    
        //just apply the scale
        self.imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, currentScale, currentScale);
    }
}

- (CGRect)currentImageRectFromInitialImage
{
    //check initial image
    if (initialImage_)
    {
        //save initial image size
        CGSize size = initialImage_.size;
        
        //get rects
        CGRect imageViewRect = self.imageView.frame;
        CGRect cropRect = self.cropView.bounds;
        
        //set parameters
        CGFloat xMin = CGRectGetMinX(imageViewRect);
        CGFloat xMax = CGRectGetMaxX(imageViewRect);
        CGFloat yMin = CGRectGetMinY(imageViewRect);
        CGFloat yMax = CGRectGetMaxY(imageViewRect);
        CGFloat xMinCrop = CGRectGetMinX(cropRect);
        CGFloat xMaxCrop = CGRectGetMaxX(cropRect);
        CGFloat yMinCrop = CGRectGetMinY(cropRect);
        CGFloat yMaxCrop = CGRectGetMaxY(cropRect);
        
        //get relative values
        CGFloat rx1 = (xMinCrop - xMin) / (xMax - xMin);
        CGFloat rx2 = (xMaxCrop - xMin) / (xMax - xMin);
        CGFloat ry1 = (yMinCrop - yMin) / (yMax - yMin);
        CGFloat ry2 = (yMaxCrop - yMin) / (yMax - yMin);
        
        return CGRectMake(size.width * rx1, size.height * ry1, size.width * (rx2 - rx1), size.height * (ry2 - ry1));
    }
    
    return CGRectZero;
}

- (void)dealloc
{
    [baseImageView_ release];
    [ddImage_ release];
    [uiImage_ release];
    [initialImage_ release];
    [topLeftCornerView release];
    [topRightCornerView release];
    [bottomLeftCornerView release];
    [bottomRightCornerView release];
    [bottomView release];
    [dimView release];
    [navigationBar release];
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

#pragma mark -
#pragma mark handlers

- (void)cancelTouched:(id)sender
{
    //inform delegate
    [self.delegate imageEditDialogViewDidCancel:self];
    
    //dismiss
    [self dismiss];
}

- (void)saveTouched:(id)sender
{    
    //inform delegate
    [self.delegate imageEditDialogView:self didCutImage:initialImage_ inRect:[self currentImageRectFromInitialImage]];
    
    //dismiss
    [self dismiss];
}

@end
