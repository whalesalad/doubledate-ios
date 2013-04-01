//
//  DDTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
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
    BOOL customized_;
}

@property(nonatomic, assign) DDTableViewCellStyle backgroundStyle;
@property(nonatomic, retain) NSObject *userData;

+ (CGFloat)height;

- (void)applyGroupedBackgroundStyleForTableView:(UITableView*)tableView withIndexPath:(NSIndexPath*)indexPath;

- (void)attachImageView:(DDImageView*)ddImageView;

- (void)customize;
- (void)customizeOnce;

@end
