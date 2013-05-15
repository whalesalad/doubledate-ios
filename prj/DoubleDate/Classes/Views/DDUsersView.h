//
//  DDUsersView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 12/24/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDUsersView : UIView
{
    NSInteger rows_;
    NSInteger columns_;
}

@property(nonatomic, retain) NSArray *users;

- (id)initWithFrame:(CGRect)frame rows:(NSInteger)rows columns:(NSInteger)columns;

@end
