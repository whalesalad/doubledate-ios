//
//  DDPhotoView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDPhotoView.h"
#import "DDImageView.h"
#import "DDImage.h"
#import "DDTools.h"
#import <QuartzCore/QuartzCore.h>

@interface DDPhotoViewContainer : NSObject

@property(nonatomic, assign) id target;
@property(nonatomic, assign) SEL action;
@property(nonatomic, assign) UIControlEvents events;

@end

@implementation DDPhotoViewContainer

@synthesize target;
@synthesize action;
@synthesize events;

@end

@implementation DDPhotoView

@synthesize label=label_;
@synthesize highlightImageView=highlightImageView_;

- (CGFloat)scale
{
    return self.frame.size.width / 122;
}

- (CGRect)rectForImageView
{
    CGFloat scale = [self scale];
    return CGRectMake(11*scale, 11*scale, 100*scale, 100*scale);
}

- (CGRect)rectForOverlay
{
    CGFloat scale = [self scale];
    return CGRectMake(8*scale, 10*scale, 106*scale, 106*scale);
}

- (CGRect)rectForHighlight
{
    CGFloat scale = [self scale];
    return CGRectMake(0, 0, 122*scale, 122*scale);
}

- (CGRect)rectForLabel
{
    CGFloat scale = [self scale];
    return CGRectMake(0, 118*scale, 122*scale, 18*scale);
}

- (CGRect)rectForButton
{
    CGFloat scale = [self scale];
    return CGRectMake(0, 0, 122*scale, 122*scale);
}

- (void)updateMask
{
    UIImage *mask = [UIImage imageNamed:@"dd-user-photo-mask.png"];
    CGFloat scale = [self scale];
    CGSize newSize = CGSizeMake(mask.size.width * scale, mask.size.height * scale);
    mask = [DDTools scaledImageFromImage:mask ofSize:newSize];
    [imageView_ applyMask:mask];
}

- (void)updateLabel
{
    CGFloat scale = [self scale];
    DD_F_GRADIENT_AVEBLK(label_);
    UIFont *font = label_.font;
    [label_ setFont:[UIFont fontWithName:font.fontName size:font.pointSize*scale]];
}

- (void)initSelf
{
    //init internal
    internal_ = [[NSMutableArray alloc] init];
    
    //unset background color
    self.backgroundColor = [UIColor clearColor];
    
    //add image view
    imageView_ = [[DDImageView alloc] init];
    imageView_.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView_];
    
    //add overlay
    overlayImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dd-user-photo-overlay.png"]];
    [self addSubview:overlayImageView_];
    
    //add highlight
    highlightImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dd-user-photo-highlighted-outline.png"]];
    highlightImageView_.hidden = YES;
    [self addSubview:highlightImageView_];
    
    //add label
    label_ = [[UILabel alloc] init];
    label_.backgroundColor = [UIColor clearColor];
    label_.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label_];
    
    //add button
    button_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    button_.backgroundColor = [UIColor clearColor];
    [self addSubview:button_];
#define ADD_HANDLING(_E_) [button_ addTarget:self action:@selector(_E_) forControlEvents:_E_]
    ADD_HANDLING(UIControlEventTouchDown);
    ADD_HANDLING(UIControlEventTouchDownRepeat);
    ADD_HANDLING(UIControlEventTouchDragInside);
    ADD_HANDLING(UIControlEventTouchDragOutside);
    ADD_HANDLING(UIControlEventTouchDragEnter);
    ADD_HANDLING(UIControlEventTouchDragExit);
    ADD_HANDLING(UIControlEventTouchUpInside);
    ADD_HANDLING(UIControlEventTouchUpOutside);
    ADD_HANDLING(UIControlEventTouchCancel);
}

- (void)applyImage:(DDImage*)image
{
    if (image && [image downloadUrl] && [NSURL URLWithString:[image downloadUrl]])
        [imageView_ reloadFromUrl:[NSURL URLWithString:[image downloadUrl]]];
    else
        imageView_.image = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        CGRect olfFrame = self.frame;
        self.frame = CGRectMake(0, 0, 122, 122);
        [self initSelf];
        self.frame = olfFrame;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        CGRect olfFrame = self.frame;
        self.frame = CGRectMake(0, 0, 122, 122);
        [self initSelf];
        self.frame = olfFrame;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    imageView_.frame = [self rectForImageView];
    overlayImageView_.frame = [self rectForOverlay];
    highlightImageView_.frame = [self rectForHighlight];
    label_.frame = [self rectForLabel];
    button_.frame = [self rectForButton];
    [self updateMask];
    [self updateLabel];
}

- (void)setHighlighted:(BOOL)highlighted
{
    highlightImageView_.hidden = !highlighted;
}

- (BOOL)isHighlighted
{
    return !highlightImageView_.hidden;
}

- (void)setText:(NSString *)text
{
    label_.text = text;
}

- (NSString*)text
{
    return label_.text;
}

- (void)dealloc
{
    [imageView_ release];
    [overlayImageView_ release];
    [highlightImageView_ release];
    [label_ release];
    [button_ release];
    [internal_ release];
    [super dealloc];
}

#pragma mark
#pragma mark UIControl

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    DDPhotoViewContainer *i = [[[DDPhotoViewContainer alloc] init] autorelease];
    i.target = target;
    i.action = action;
    i.events = controlEvents;
    [internal_ addObject:i];
}

#define IMPL_HANDLING(_E_)\
- (void)_E_\
{\
    for (DDPhotoViewContainer *d in internal_)\
    {\
        if (d.events & _E_)\
            [d.target performSelector:d.action withObject:self];\
    }\
}

IMPL_HANDLING(UIControlEventTouchDown)
IMPL_HANDLING(UIControlEventTouchDownRepeat)
IMPL_HANDLING(UIControlEventTouchDragInside)
IMPL_HANDLING(UIControlEventTouchDragOutside)
IMPL_HANDLING(UIControlEventTouchDragEnter)
IMPL_HANDLING(UIControlEventTouchDragExit)
IMPL_HANDLING(UIControlEventTouchUpInside)
IMPL_HANDLING(UIControlEventTouchUpOutside)
IMPL_HANDLING(UIControlEventTouchCancel)

- (NSSet *)allTargets
{
    NSMutableSet *ret = [NSMutableSet set];
    for (DDPhotoViewContainer *d in internal_)
        [ret addObject:d.target];
    return ret;
}

- (UIControlEvents)allControlEvents
{
    UIControlEvents ret = 0;
    for (DDPhotoViewContainer *d in internal_)
        ret = ret | d.events;
    return ret;
}

- (NSArray *)actionsForTarget:(id)target forControlEvent:(UIControlEvents)controlEvent
{
    NSMutableArray *ret = [NSMutableArray array];
    for (DDPhotoViewContainer *d in internal_)
    {
        if ((d.target == target) && (d.events & controlEvent))
            [ret addObject:NSStringFromSelector(d.action)];
    }
    return ret;
}

@end
