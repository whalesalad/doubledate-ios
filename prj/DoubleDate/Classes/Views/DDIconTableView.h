//
//  DDIconTableView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewCell.h"

@interface DDIconTableView : DDTableViewCell
{
    UIImageView *icon_;
    UITextField *leftLabel_;
    UITextField *rightLabelText_;
    UITextField *rightLabelPlaceholder_;
}

@property(nonatomic, retain) UIImage *image;
@property(nonatomic, retain) NSString *leftText;
@property(nonatomic, retain) NSString *rightText;
@property(nonatomic, retain) NSString *rightPlaceholder;

@end
