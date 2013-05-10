//
//  DDWingTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
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
@synthesize viewEffects;

+ (CGFloat)height
{
    return 198;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)customizeOnce
{    
    viewEffects.layer.borderColor = [UIColor blackColor].CGColor;
    viewEffects.layer.borderWidth = 1;

    viewEffects.layer.shadowColor = [UIColor blackColor].CGColor;
    viewEffects.layer.shadowOffset = CGSizeMake(0, 1);
    viewEffects.layer.shadowRadius = 1;
    viewEffects.layer.shadowOpacity = 0.4f;
    viewEffects.layer.shadowPath = [[UIBezierPath bezierPathWithRect:viewEffects.bounds] CGPath];
    
    imageViewPoster.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1].CGColor;
    imageViewPoster.layer.borderWidth = 1;
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
    if (v.photo.squareUrl && [NSURL URLWithString:v.photo.squareUrl])
        [imageViewPoster reloadFromUrl:[NSURL URLWithString:v.photo.squareUrl]];
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
    NSString *name = [user.firstName capitalizedString];
    if (!name)
        name = [user.name capitalizedString];
    if (!name)
        name = user.fullName;
    NSString *age = user.age?[NSString stringWithFormat:@", %d", [user.age intValue]]:@"";
    return [NSString stringWithFormat:@"%@%@", name, age];
}

+ (NSString*)titleForUser:(DDUser*)user
{
    return [NSString stringWithFormat:@"%@, %d", [user.firstName capitalizedString], [user.age intValue]];
}

- (void)dealloc
{
    [shortUser release];
    [imageViewPoster release];
    [labelTitle release];
    [labelLocation release];
    [imageViewGender release];
    [viewEffects release];
    [super dealloc];
}

@end
