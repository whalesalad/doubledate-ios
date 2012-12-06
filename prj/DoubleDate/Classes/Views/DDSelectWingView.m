//
//  DDSelectWingView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDSelectWingView.h"
#import "DDAPIController.h"
#import "DDShortUser.h"
#import "DDPhotoView.h"

@interface DDSelectWingViewContainer : NSObject

@property(nonatomic, retain) DDPhotoView *photoView;
@property(nonatomic, retain) DDShortUser *shortUser;

@end

@implementation DDSelectWingViewContainer

@synthesize photoView;
@synthesize shortUser;

- (void)dealloc
{
    [photoView release];
    [shortUser release];
    [super dealloc];
}

@end

@interface DDSelectWingView (API) <DDAPIControllerDelegate>

- (CGPoint)positionForViewIndex:(NSInteger)index;
- (CGSize)sizeForViewIndex:(NSInteger)index;
- (void)applyUIForView:(UIView*)view ofViewIndex:(NSInteger)index;
- (DDSelectWingViewContainer*)containerForViewIndex:(NSInteger)index;

- (void)applyChange:(NSInteger)direction;

- (void)recreateFromWings:(NSArray*)array;

- (DDSelectWingViewContainer*)leftContainerForContainer:(DDSelectWingViewContainer*)container;
- (DDSelectWingViewContainer*)rightContainerForContainer:(DDSelectWingViewContainer*)container;

@end

@implementation DDSelectWingView

@synthesize delegate;

- (void)initSelf
{
    //add api controller
    apiController_ = [[DDAPIController alloc] init];
    apiController_.delegate = self;
    
    //add loading
    loading_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loading_.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    loading_.hidesWhenStopped = YES;
    loading_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:loading_];
    
    //add photo views
    containers_ = [[NSMutableArray alloc] init];
    
    //add gesture recognizers
    UISwipeGestureRecognizer *gestureRecognizerRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)] autorelease];
    [gestureRecognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self addGestureRecognizer:gestureRecognizerRight];
    UISwipeGestureRecognizer *gestureRecognizerLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)] autorelease];
    [gestureRecognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:gestureRecognizerLeft];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self initSelf];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initSelf];
    }
    return self;
}

- (void)dealloc
{
    apiController_.delegate = nil;
    [apiController_ release];
    [loading_ release];
    [containers_ release];
    [super dealloc];
}

- (void)swipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    //check state
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        //check available data
        if (![containers_ count])
            return;
        
        //update index
        NSInteger direction = 0;
        if ([gestureRecognizer direction] == UISwipeGestureRecognizerDirectionRight)
            direction--;
        else if ([gestureRecognizer direction] == UISwipeGestureRecognizerDirectionLeft)
            direction++;
        
        //update UI
        [self applyChange:direction];
    }
}

- (CGSize)sizeForViewIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            return CGSizeMake(122, 122);
            break;
        default:
            break;
    }
    return CGSizeMake(61, 61);
}

- (CGPoint)positionForViewIndex:(NSInteger)index
{
    switch (index) {
        case -1:
            return CGPointMake(self.frame.size.width/2-100, self.frame.size.height/2);
            break;
        case 0:
            return CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
            break;
        case 1:
            return CGPointMake(self.frame.size.width/2+100, self.frame.size.height/2);
            break;
        default:
            break;
    }
    return CGPointMake(self.frame.size.width/2, self.frame.size.height/2-1);
}

- (void)applyUIForView:(UIView *)view ofViewIndex:(NSInteger)index
{
    CGSize newSize = [self sizeForViewIndex:index];
    CGPoint newCenter = [self positionForViewIndex:index];
    view.frame = CGRectMake(newCenter.x - newSize.width/2, newCenter.y - newSize.height/2, newSize.width, newSize.height);
}

- (DDSelectWingViewContainer*)containerForViewIndex:(NSInteger)index
{
    CGPoint neededPosition = [self positionForViewIndex:index];
    for (DDSelectWingViewContainer *container in containers_)
    {
        if (CGPointEqualToPoint(container.photoView.center, neededPosition))
            return container;
    }
    return nil;
}

- (DDSelectWingViewContainer*)leftContainerForContainer:(DDSelectWingViewContainer*)container
{
    //get index
    NSInteger index = [containers_ indexOfObject:container];

    //check if found
    if (index == NSNotFound)
        return container;
    
    //change index
    index--;
    
    //check for zero
    if (index < 0)
        index = [containers_ count] - 1;
    
    return [containers_ objectAtIndex:index];
}

- (DDSelectWingViewContainer*)rightContainerForContainer:(DDSelectWingViewContainer*)container
{
    //get index
    NSInteger index = [containers_ indexOfObject:container];
    
    //check if found
    if (index == NSNotFound)
        return container;
    
    //change index
    index++;
    
    //check for zero
    if (index >= [containers_ count])
        index = 0;
    
    return [containers_ objectAtIndex:index];
}

- (void)applyChange:(NSInteger)direction
{
    //get containers
    DDSelectWingViewContainer *main = [self containerForViewIndex:0];
    DDSelectWingViewContainer *left = [self leftContainerForContainer:main];
    DDSelectWingViewContainer *leftLeft = [self leftContainerForContainer:left];
    DDSelectWingViewContainer *right = [self rightContainerForContainer:main];
    DDSelectWingViewContainer *rightRight = [self rightContainerForContainer:right];
    
    //check direction
    if (direction == 1)
    {
        [self applyUIForView:main.photoView ofViewIndex:-1];
        [self applyUIForView:right.photoView ofViewIndex:0];
        [self bringSubviewToFront:right.photoView];
        [self applyUIForView:rightRight.photoView ofViewIndex:1];
        [self applyUIForView:left.photoView ofViewIndex:-2];
    }
    else if (direction == -1)
    {
        [self applyUIForView:main.photoView ofViewIndex:1];
        [self applyUIForView:left.photoView ofViewIndex:0];
        [self bringSubviewToFront:left.photoView];
        [self applyUIForView:leftLeft.photoView ofViewIndex:-1];
        [self applyUIForView:right.photoView ofViewIndex:2];
    }
    else
        [self bringSubviewToFront:main.photoView];
    
    //inform delegate about change
    [self.delegate selectWingViewDidSelectWing:self];
}

- (void)start
{
    //show loading
    [loading_ startAnimating];
    
    //make a request
    [apiController_ getFriends];
}

- (DDShortUser*)wing
{
    DDShortUser *ret = [(DDSelectWingViewContainer*)[self containerForViewIndex:0] shortUser];
    NSLog(@"%@", [ret firstName]);
    return ret;
}

- (void)recreateFromWings:(NSArray*)wings
{
    //remove old one
    while ([containers_ count])
    {
        DDSelectWingViewContainer *container = [containers_ lastObject];
        [container.photoView removeFromSuperview];
        [containers_ removeObject:container];
    }
    
    //add new
    for (int i = 0; i < [wings count]; i++)
    {
        //create new photo view
        NSInteger index = i - [wings count] / 2;
        DDPhotoView *photoView = [[[DDPhotoView alloc] init] autorelease];
        [self applyUIForView:photoView ofViewIndex:index];
        [self addSubview:photoView];
        
        //extract short user
        DDShortUser *shortUser = (DDShortUser*)[wings objectAtIndex:i];
        
        //update UI
        [photoView setText:[shortUser firstName]];
        [photoView applyImage:[shortUser photo]];
        
        //set dependency
        DDSelectWingViewContainer *container = [[[DDSelectWingViewContainer alloc] init] autorelease];
        container.photoView = photoView;
        container.shortUser = shortUser;
        [containers_ addObject:container];
    }
}

#pragma mark -
#pragma mark DDAPIControllerDelegate

- (void)getFriendsSucceed:(NSArray*)friends
{
    //stop loading
    [loading_ stopAnimating];
    
    //recreate photo views
    [self recreateFromWings:friends];
    
    //apply change
    [self applyChange:0];
}

- (void)getFriendsDidFailedWithError:(NSError*)error
{
    //stop loading
    [loading_ stopAnimating];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

@end
