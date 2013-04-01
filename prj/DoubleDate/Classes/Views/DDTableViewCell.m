//
//  DDTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDTableViewCell.h"
#import "DDTools.h"
#import "DDImageView.h"

@implementation DDTableViewCell

@synthesize backgroundStyle;
@synthesize userData;

+ (CGFloat)height
{
    return 50;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        self.backgroundStyle = DDTableViewCellStyleNone;
        self.backgroundColor = [UIColor clearColor];
        DD_F_TABLE_CELL_MAIN(self.textLabel);
        DD_F_TABLE_CELL_DETAILED(self.detailTextLabel);
        self.textLabel.shadowColor = [UIColor blackColor];
        self.detailTextLabel.shadowColor = [UIColor blackColor];
    }
    return self;
}

- (void)unsetScrollsToTopForView:(UIView*)view
{
    //unset flag
    if ([view isKindOfClass:[UIScrollView class]])
        [(UIScrollView*)view setScrollsToTop:NO];

    //make for child
    for (UIView *subview in [view subviews])
        [self unsetScrollsToTopForView:subview];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //unset scrolls to top flag
    [self unsetScrollsToTopForView:self];
    
    //check if already customized
    if (!customized_)
    {
        customized_ = YES;
        [self customizeOnce];
    }
    
    //customize self
    [self customize];
}

- (void)customize
{
}

- (void)customizeOnce
{
}

- (void)setBackgroundStyle:(DDTableViewCellStyle)v
{
    //apply value
    backgroundStyle = v;
    
    //switch background image name
    NSString *backgroundImageName = nil;
    NSString *selectedBackgroundImageName = nil;
    switch (v) {
        case DDTableViewCellStyleNone:
            backgroundImageName = nil;
            selectedBackgroundImageName = nil;
            break;
        case DDTableViewCellStylePlain:
            backgroundImageName = @"dd-tablecell-background.png";
            selectedBackgroundImageName = nil;
            break;
        case DDTableViewCellStyleGroupedTop:
            backgroundImageName = @"dd-tableview-cell-top.png";
            selectedBackgroundImageName = @"dd-tableview-cell-top-highlighted.png";
            break;
        case DDTableViewCellStyleGroupedCenter:
            backgroundImageName = @"dd-tableview-cell-center.png";
            selectedBackgroundImageName = @"dd-tableview-cell-center-highlighted.png";
            break;
        case DDTableViewCellStyleGroupedBottom:
            backgroundImageName = @"dd-tableview-cell-bottom.png";
            selectedBackgroundImageName = @"dd-tableview-cell-bottom-highlighted.png";
            break;
        case DDTableViewCellStyleGroupedSolid:
            backgroundImageName = @"dd-tableview-cell-single.png";
            selectedBackgroundImageName = @"dd-tableview-cell-single-highlighted.png";
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
    
    //check selected background image name
    if (selectedBackgroundImageName)
    {
        self.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[DDTools resizableImageFromImage:[UIImage imageNamed:selectedBackgroundImageName]]] autorelease];
    }
    else
        self.selectedBackgroundView = nil;
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

- (void)attachImageView:(DDImageView*)ddImageView
{
    //check image view
    if (ddImageView)
    {
        //remove all previous
        for (DDImageView *child in [self.imageView subviews])
        {
            if ([child isKindOfClass:[DDImageView class]])
                ddImageView = child;
        }
        
        //set needed size
        self.imageView.image = [DDTools clearImageOfSize:ddImageView.frame.size];
        
        //applt needed frame
        ddImageView.frame = CGRectMake(0, 0, ddImageView.frame.size.width, ddImageView.frame.size.height);
        
        //add image view
        if (![[self.imageView subviews] containsObject:ddImageView])
            [self.imageView addSubview:ddImageView];
    }
    else
        self.imageView.image = nil;
}

- (void)dealloc
{
    [userData release];
    [super dealloc];
}

@end
