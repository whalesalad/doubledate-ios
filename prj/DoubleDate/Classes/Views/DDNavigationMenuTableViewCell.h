//
//  DDNavigationMenuTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTableViewCell.h"

@interface DDNavigationMenuTableViewCell : UITableViewCell
{
    CGRect labelRect_;
    CGRect imageViewRect_;
}

@property(nonatomic, retain) IBOutlet UIImageView *imageViewIcon;
@property(nonatomic, retain) IBOutlet UILabel *labelTitle;

@property(nonatomic, retain) UIView *highlightLine;

@property(nonatomic, assign) NSInteger badgeNumber;

@property(nonatomic, assign) BOOL blueStyle;

- (void)drawShadowForView:(UIView *)aView;

+ (CGFloat)height;

@end
