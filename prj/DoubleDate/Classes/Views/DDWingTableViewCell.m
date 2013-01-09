//
//  DDWingTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDWingTableViewCell.h"
#import "DDUser.h"
#import "DDShortUser.h"
#import "DDImageView.h"
#import "DDImage.h"
#import <QuartzCore/QuartzCore.h>

@implementation DDWingTableViewCell

@synthesize shortUser;

@synthesize imageViewPoster;
@synthesize labelTitle;
@synthesize labelLocation;
@synthesize imageViewGender;

+ (CGFloat)height
{
    return 200;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
#warning customize here
    imageViewPoster.layer.borderColor = [UIColor redColor].CGColor;
    imageViewPoster.layer.borderWidth = 2;
    imageViewPoster.layer.shadowColor = [UIColor greenColor].CGColor;
    imageViewPoster.layer.shadowOffset = CGSizeMake(0, 2);
    imageViewPoster.layer.shadowOpacity = 1;
}

- (void)setShortUser:(DDShortUser *)v
{
    //apply new value
    if (v != shortUser)
    {
        [shortUser release];
        shortUser = [v retain];
    }
    
    //update ui
    imageViewPoster.image = nil;
    if (v.photo.mediumUrl && [NSURL URLWithString:v.photo.mediumUrl])
        [imageViewPoster reloadFromUrl:[NSURL URLWithString:v.photo.mediumUrl]];
    labelTitle.text = [DDWingTableViewCell titleForShortUser:v];
    labelTitle.frame = CGRectMake(labelTitle.frame.origin.x, labelTitle.frame.origin.y, [labelTitle sizeThatFits:labelTitle.bounds.size].width, labelTitle.frame.size.height);
    labelLocation.text = v.location;
    if ([[v gender] isEqualToString:DDUserGenderFemale])
        imageViewGender.image = [UIImage imageNamed:@"icon-gender-female.png"];
    else
        imageViewGender.image = [UIImage imageNamed:@"icon-gender-male.png"];
    imageViewGender.frame = CGRectMake(labelTitle.frame.origin.x+labelTitle.frame.size.width+4, labelTitle.center.y-imageViewGender.image.size.height/2, imageViewGender.image.size.width, imageViewGender.image.size.height);
}

+ (NSString*)titleForShortUser:(DDShortUser*)user
{
    NSString *name = user.fullName?[user.fullName capitalizedString]:[user.name capitalizedString];
    NSString *age = user.age?[NSString stringWithFormat:@", %d", [user.age intValue]]:@"";
    return [NSString stringWithFormat:@"%@%@", name, age];
}

+ (NSString*)titleForUser:(DDUser*)user
{
    return [NSString stringWithFormat:@"%@ %@, %d", [user.firstName capitalizedString], [user.lastName capitalizedString], [user.age intValue]];
}

- (void)dealloc
{
    [shortUser release];
    [imageViewPoster release];
    [labelTitle release];
    [labelLocation release];
    [imageViewGender release];
    [super dealloc];
}

@end
