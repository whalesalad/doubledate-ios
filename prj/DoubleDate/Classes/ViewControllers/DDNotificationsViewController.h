//
//  DDNotificationsViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 08.10.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewController.h"

@interface DDNotificationsViewController : DDTableViewController
{
    DDRequestId notificationsRequest_;
    NSMutableArray *notifications_;
}

@end
