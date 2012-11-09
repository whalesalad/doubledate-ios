//
//  DDCreateDoubleDateViewControllerChooseWing.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/24/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDViewController.h"

@class DDShortUser;

@protocol DDCreateDoubleDateViewControllerChooseWingDelegate <NSObject>

- (void)createDoubleDateViewControllerChooseWingUpdatedWing:(id)sender;

@end

@interface DDCreateDoubleDateViewControllerChooseWing : DDViewController
{
    UITableView *tableView_;
    NSArray *wings_;
}

@property(nonatomic, retain) DDShortUser *wing;

@property(nonatomic, assign) id<DDCreateDoubleDateViewControllerChooseWingDelegate> delegate;

@end
