//
//  DDTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewCell.h"
#import "DDTools.h"

@implementation DDTableViewCell

@synthesize backgroundStyle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        self.backgroundStyle = DDTableViewCellStyleNone;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setBackgroundStyle:(DDTableViewCellStyle)v
{
    //apply value
    backgroundStyle = v;
    
    //switch background image name
    NSString *backgroundImageName = nil;
    switch (v) {
        case DDTableViewCellStyleNone:
            backgroundImageName = nil;
            break;
        case DDTableViewCellStylePlain:
            backgroundImageName = @"dd-tablecell-background.png";
            break;
        case DDTableViewCellStyleGroupedTop:
            backgroundImageName = @"dd-tableview-cell-top.png";
            break;
        case DDTableViewCellStyleGroupedCenter:
            backgroundImageName = @"dd-tableview-cell-center.png";
            break;
        case DDTableViewCellStyleGroupedBottom:
            backgroundImageName = @"dd-tableview-cell-bottom.png";
            break;
        case DDTableViewCellStyleGroupedSolid:
            backgroundImageName = @"dd-tableview-cell-center.png";
            break;
        default:
            break;
    }
    
    //check background image name
    if (backgroundImageName)
    {
        self.backgroundView = [[[UIImageView alloc] initWithImage:[DDTools resizableImageFromImage:[UIImage imageNamed:backgroundImageName]]] autorelease];
    }
    else
        self.backgroundView = nil;
}

- (void)applyGroupedBackgroundStyleForTableView:(UITableView*)tableView withIndexPath:(NSIndexPath*)indexPath
{
    DDTableViewCellStyle style = DDTableViewCellStyleNone;
    if ([tableView numberOfRowsInSection:indexPath.section] <= 1)
        style = DDTableViewCellStyleGroupedSolid;
    else if (indexPath.row == 0)
        style = DDTableViewCellStyleGroupedTop;
    else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1)
        style = DDTableViewCellStyleGroupedBottom;
    else
        style = DDTableViewCellStyleGroupedCenter;
    self.backgroundStyle = style;
}

- (void)dealloc
{
    [super dealloc];
}

@end
