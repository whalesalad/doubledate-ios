//
//  DDTextFieldTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTableViewCell.h"

@class DDTextField;

@interface DDTextFieldTableViewCell : DDTableViewCell
{
    DDTextField *textField_;
}

@property(nonatomic, readonly) DDTextField *textField;

@end
