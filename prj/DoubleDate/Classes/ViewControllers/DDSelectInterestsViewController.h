//
//  DDSelectInterestsViewController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 08.10.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewController.h"

@interface DDSelectInterestsViewController : DDTableViewController
{
    DDRequestId request_;
    NSArray *allInterests_;
}

@property(nonatomic, retain) NSArray *selectedInterests;
@property(nonatomic, assign) NSInteger maxInterestsCount;

@end
