//
//  DDInAppProductTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTableViewCell.h"

@interface DDInAppProductTableViewCell : DDTableViewCell
{
}

@property(nonatomic, retain) IBOutlet UILabel *labelAmount;
@property(nonatomic, retain) IBOutlet UILabel *labelCost;
@property(nonatomic, retain) IBOutlet UILabel *labelPopular;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewPopular;

@end
