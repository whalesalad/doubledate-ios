//
//  DDNotificationsViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 08.10.12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTableViewController.h"

@interface DDNotificationsViewController : DDTableViewController
{
    DDRequestId notificationsRequest_;
    NSMutableArray *notifications_;
}

@end
