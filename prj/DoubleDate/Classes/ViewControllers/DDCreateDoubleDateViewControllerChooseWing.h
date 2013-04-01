//
//  DDCreateDoubleDateViewControllerChooseWing.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/24/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTableViewController.h"

@class DDShortUser;

@protocol DDCreateDoubleDateViewControllerChooseWingDelegate <NSObject>

- (void)createDoubleDateViewControllerChooseWingUpdatedWing:(id)sender;

@end

@interface DDCreateDoubleDateViewControllerChooseWing : DDTableViewController
{
    NSArray *wings_;
}

@property(nonatomic, retain) DDShortUser *wing;

@property(nonatomic, assign) id<DDCreateDoubleDateViewControllerChooseWingDelegate> delegate;

@end
