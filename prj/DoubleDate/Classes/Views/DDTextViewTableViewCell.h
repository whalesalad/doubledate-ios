//
//  DDTextViewTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTableViewCell.h"

@class DDTextView;

@interface DDTextViewTableViewCell : DDTableViewCell
{
    DDTextView *textView_;
}

@property(nonatomic, readonly) DDTextView *textView;

@end
