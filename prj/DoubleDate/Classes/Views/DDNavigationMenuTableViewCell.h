//
//  DDNavigationMenuTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewCell.h"

@interface DDNavigationMenuTableViewCell : UITableViewCell
{
}

@property(nonatomic, retain) IBOutlet UIImageView *imageViewIcon;
@property(nonatomic, retain) IBOutlet UILabel *labelTitle;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewBadge;
@property(nonatomic, retain) IBOutlet UILabel *labelBadge;
@property(nonatomic, retain) IBOutlet UIView *highlightLine;

- (void)drawShadowForView:(UIView *)aView;

+ (CGFloat)height;

@end
