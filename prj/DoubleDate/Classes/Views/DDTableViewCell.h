//
//  DDTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDImageView;

typedef enum
{
    DDTableViewCellStyleNone,
    DDTableViewCellStylePlain,
    DDTableViewCellStyleGroupedTop,
    DDTableViewCellStyleGroupedCenter,
    DDTableViewCellStyleGroupedBottom,
    DDTableViewCellStyleGroupedSolid
} DDTableViewCellStyle;

@interface DDTableViewCell : UITableViewCell
{
}

@property(nonatomic, assign) DDTableViewCellStyle backgroundStyle;
@property(nonatomic, retain) NSObject *userData;

+ (CGFloat)height;

- (void)applyGroupedBackgroundStyleForTableView:(UITableView*)tableView withIndexPath:(NSIndexPath*)indexPath;

- (void)attachImageView:(DDImageView*)ddImageView;

@end
