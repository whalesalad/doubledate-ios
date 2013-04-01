//
//  DDSelectInterestsViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 08.10.12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDViewController.h"

@class DDSelectInterestsViewController;
@class DDInterest;

@protocol DDSelectInterestsViewControllerDelegate <NSObject>

- (void)selectInterestsViewController:(DDSelectInterestsViewController*)viewController didSelectInterest:(DDInterest*)interest;
- (void)selectInterestsViewControllerDidCancel:(DDSelectInterestsViewController*)viewController;

@end

@interface DDSelectInterestsViewController : DDViewController
{
    DDRequestId request_;
    NSArray *allInterests_;
    NSArray *interestsToShow_;
}

@property(nonatomic, assign) id<DDSelectInterestsViewControllerDelegate> delegate;

@property(nonatomic, retain) NSArray *selectedInterests;
@property(nonatomic, assign) NSInteger maxInterestsCount;

@end
