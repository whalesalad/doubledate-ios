//
//  DDIconTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTableViewCell.h"

@class DDImageView;

@interface DDIconTableViewCell : DDTableViewCell
{
    DDImageView *iconImageView_;
    UITextField *leftLabel_;
    UITextField *rightLabelText_;
    UITextField *rightLabelPlaceholder_;
}

@property(nonatomic, readonly) DDImageView *iconImageView;

@property(nonatomic, retain) NSString *leftText;
@property(nonatomic, retain) NSString *rightText;
@property(nonatomic, retain) NSString *rightPlaceholder;

@end
