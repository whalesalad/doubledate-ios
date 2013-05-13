//
//  DDUserView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 12/24/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDUserView.h"
#import "DDShortUser.h"
#import "DDUser.h"
#import "DDImageView.h"
#import "DDImage.h"
#import "DDFacebookFriendsViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation DDUserView

@synthesize customTitle;
@synthesize shortUser;
@synthesize user;

@synthesize imageViewPhoto;
@synthesize imageViewGender;
@synthesize labelTitle;

- (NSString*)photoUrl
{
    if (self.user)
    {
        if (self.user.photo.squareUrl)
            return self.user.photo.squareUrl;
        return self.user.photo.thumbUrl;
    }
    else if (self.shortUser)
    {
        if (self.shortUser.photo.squareUrl)
            return self.shortUser.photo.squareUrl;
        return self.shortUser.photo.thumbUrl;
    }
    return nil;
}

- (NSString*)gender
{
    if (self.user)
        return self.user.gender;
    else if (self.shortUser)
        return self.shortUser.gender;
    return nil;
}

- (NSString*)name
{
    if (self.customTitle)
        return self.customTitle;
    else if (self.user)
        return self.user.firstName;
    else if (self.shortUser)
    {
        if (self.shortUser.firstName)
            return self.shortUser.firstName;
        return self.shortUser.fullName;
    }
    return nil;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.imageViewPhoto.layer.cornerRadius = 6;
    self.imageViewPhoto.clipsToBounds = YES;
}

- (void)updateUI
{
    //reload the image
    self.imageViewPhoto.image = nil;
    [self.imageViewPhoto reloadFromUrl:[NSURL URLWithString:[self photoUrl]]];
    
    //update gender
    self.imageViewGender.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-indicator-small.png", self.gender]];
    
    //make correct positioning
    CGFloat dx = CGRectGetMinX(self.labelTitle.frame) - CGRectGetMaxX(self.imageViewGender.frame);
    
    //update name
    CGFloat labelWidth = MIN([[self name] sizeWithFont:self.labelTitle.font].width, 100);
    self.labelTitle.frame = CGRectMake(0, self.labelTitle.frame.origin.y, labelWidth, self.labelTitle.frame.size.height);
    self.labelTitle.text = [self name];
    
    //calculate the overall width
    CGFloat overallWidth = self.labelTitle.frame.size.width + self.imageViewGender.frame.size.width + dx;
    
    //layout gender
    self.imageViewGender.frame = CGRectMake(self.frame.size.width / 2 - overallWidth / 2, self.imageViewGender.frame.origin.y, self.imageViewGender.frame.size.width, self.imageViewGender.frame.size.height);
    
    //layout label
    self.labelTitle.frame = CGRectMake(CGRectGetMaxX(self.imageViewGender.frame) + dx, self.labelTitle.frame.origin.y, self.labelTitle.frame.size.width, self.labelTitle.frame.size.height);
}

- (void)setShortUser:(DDShortUser *)v
{
    //unset user
    [user release];
    user = nil;
    
    //update short user
    if (v != self.shortUser)
    {
        [shortUser release];
        shortUser = [v retain];
    }
    
    //update UI
    [self updateUI];
}

- (void)setUser:(DDUser *)v
{
    //unset user
    [shortUser release];
    shortUser = nil;
    
    //update short user
    if (v != self.user)
    {
        [user release];
        user = [v retain];
    }
    
    //update UI
    [self updateUI];
}

- (void)setCustomTitle:(NSString *)v
{
    //update title
    if (v != self.customTitle)
    {
        [customTitle release];
        customTitle = [v retain];
    }
    
    //update UI
    [self updateUI];
}

- (void)dealloc
{
    [customTitle release];
    [shortUser release];
    [user release];
    [imageViewPhoto release];
    [imageViewGender release];
    [labelTitle release];
    [super dealloc];
}

@end
