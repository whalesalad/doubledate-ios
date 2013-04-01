//
//  DDCreateDoubleDateViewControllerChooseDate.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDViewController.h"

@protocol DDCreateDoubleDateViewControllerChooseDateDelegate <NSObject>

- (void)createDoubleDateViewControllerChooseDateUpdatedDayTime:(id)sender;

@end

@interface DDCreateDoubleDateViewControllerChooseDate : DDViewController
{
    UITableView *tableView_;
}

@property(nonatomic, assign) id<DDCreateDoubleDateViewControllerChooseDateDelegate> delegate;

@property(nonatomic, retain) NSString *day;
@property(nonatomic, retain) NSString *time;

@end
