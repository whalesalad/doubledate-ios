//
//  DDTableViewCell.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation DDTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        UIImage *image = [UIImage imageNamed:@"dd-tablecell-background.png"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2, image.size.width/2, image.size.height/2, image.size.width/2)];
        self.backgroundView = [[[UIImageView alloc] initWithImage:image] autorelease];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
