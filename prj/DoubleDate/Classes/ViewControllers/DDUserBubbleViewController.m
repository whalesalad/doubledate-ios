//
//  DDUserBubbleViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 11/20/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDUserBubbleViewController.h"
#import "DDUser.h"
#import "DDLocationTableViewCell.h"
#import "DDPlacemark.h"
#import "DDInterest.h"
#import "DDTools.h"

@interface DDUserBubbleViewController ()

- (UIFont*)fontForTitle;
- (UIFont*)fontForLocation;
- (UIFont*)fontForBio;
- (UIFont*)fontForInterests;

@end

@implementation DDUserBubbleViewController

@synthesize heightOffset=heightOffset_;

@synthesize user;

@synthesize labelTitle;
@synthesize labelLocation;
@synthesize textViewInfo;
@synthesize viewInterests;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //unset background color
    self.labelTitle.backgroundColor = [UIColor clearColor];
    self.labelLocation.backgroundColor = [UIColor clearColor];
    self.textViewInfo.backgroundColor = [UIColor clearColor];
    self.viewInterests.backgroundColor = [UIColor clearColor];
    
    //fill data
    self.labelTitle.text = [NSString stringWithFormat:@"%@, %d", [self.user firstName], [[self.user age] intValue]];
    self.labelTitle.text = [self.labelTitle.text uppercaseString];
    self.labelLocation.text = self.user.location.name;
    self.textViewInfo.text = self.user.bio;
    
    //apply fonts
    self.labelTitle.font = [self fontForTitle];
    self.labelLocation.font = [self fontForLocation];
    self.textViewInfo.font = [self fontForBio];
    
    //customize geometry
    CGFloat labelTitleHeight = self.labelTitle.frame.size.height;
    [self.labelTitle sizeToFit];
    self.labelTitle.frame = CGRectMake(self.labelTitle.frame.origin.x, self.labelTitle.frame.origin.y, self.labelTitle.frame.size.width, labelTitleHeight);
    
    //add gender image
    UIImage *genderImage = [UIImage imageNamed:[self.user.gender isEqualToString:DDUserGenderMale]?@"dd-user-gender-indicator-male.png":@"dd-user-gender-indicator-female.png"];
    UIImageView *genderImageView = [[[UIImageView alloc] initWithImage:genderImage] autorelease];
    genderImageView.frame = CGRectMake(self.labelTitle.frame.origin.x + self.labelTitle.frame.size.width + 4, (labelTitleHeight-genderImage.size.height)/2+2, genderImage.size.width, genderImage.size.height);
    [self.labelTitle.superview addSubview:genderImageView];
    
    //save difference in height
    CGRect oldBioFrame = self.textViewInfo.frame;
    [self.textViewInfo sizeToFit];
    CGFloat newBioHeight = self.textViewInfo.frame.size.height;
    newBioHeight = MIN(MAX(newBioHeight, 20), 180);
    self.textViewInfo.frame = CGRectMake(oldBioFrame.origin.x, oldBioFrame.origin.y, oldBioFrame.size.width, newBioHeight);
    CGFloat dhBio = self.textViewInfo.frame.size.height - oldBioFrame.size.height;
    
    //offset interests
    self.viewInterests.frame = CGRectMake(self.viewInterests.frame.origin.x, self.viewInterests.frame.origin.y+dhBio, self.viewInterests.frame.size.width, self.viewInterests.frame.size.height);
    
    //add interesets
    CGFloat outHorPadding = 4;
    CGFloat outVerPadding = 6;
    CGFloat curX = outHorPadding;
    CGFloat curY = outVerPadding;
    CGFloat totalInterestsHeight = 0;
    CGRect oldInterestsFrame = self.viewInterests.frame;
    for (DDInterest *interest in self.user.interests)
    {
        //edge padding inside the bubble
        CGFloat inEdgePadding = 6;
        
        //create label
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        //label.font = [self fontForInterests];
        DD_F_BUBBLE_INTEREST_TEXT(label);
        label.text = [interest.name uppercaseString];
        label.backgroundColor = [UIColor clearColor];
        [label sizeToFit];
        
        //create background image
        UIImage *labelBackgroundImage = [UIImage imageNamed:@"dd-user-bubble-interest-item.png"];
        UIImageView *labelBackground = [[[UIImageView alloc] initWithFrame:CGRectMake(curX, curY, label.frame.size.width+2*inEdgePadding, labelBackgroundImage.size.height)] autorelease];
        labelBackground.image = [DDTools resizableImageFromImage:labelBackgroundImage];
        
        //add label
        label.center = CGPointMake(labelBackground.frame.size.width/2, labelBackground.frame.size.height/2-1);
        [labelBackground addSubview:label];
        
        //add image view
        [self.viewInterests addSubview:labelBackground];
        
        //move horizontally
        curX = labelBackground.frame.origin.x + labelBackground.frame.size.width + outHorPadding;
        
        //check if out of the bounds
        if (curX > self.viewInterests.frame.size.width)
        {
            //update current frame
            curY = labelBackground.frame.origin.y + labelBackground.frame.size.height + outVerPadding;
            curX = outHorPadding;
            labelBackground.frame = CGRectMake(curX, curY, labelBackground.frame.size.width, labelBackground.frame.size.height);

            //set up new frame
            curX = labelBackground.frame.origin.x + labelBackground.frame.size.width + outHorPadding;
        }
        
        //save total height
        totalInterestsHeight = labelBackground.frame.origin.y + labelBackground.frame.size.height + outVerPadding;
    }
    CGFloat newInterestsHeight = totalInterestsHeight;
    newInterestsHeight = MIN(MAX(newInterestsHeight, 0), 94);
    self.viewInterests.frame = CGRectMake(oldInterestsFrame.origin.x, oldInterestsFrame.origin.y, oldInterestsFrame.size.width, newInterestsHeight);
    CGFloat dhInterests = self.viewInterests.frame.size.height - oldInterestsFrame.size.height;
    
    //save height offset
    heightOffset_ = dhBio + dhInterests;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [labelTitle release], labelTitle = nil;
    [labelLocation release], labelLocation = nil;
    [textViewInfo release], textViewInfo = nil;
    [viewInterests release], viewInterests = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [user release];
    [labelTitle release];
    [labelLocation release];
    [textViewInfo release];
    [viewInterests release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (UIFont*)fontForTitle
{
    return [UIFont boldSystemFontOfSize:14];
}

- (UIFont*)fontForLocation
{
    return [UIFont systemFontOfSize:13];
}

- (UIFont*)fontForBio
{
    return [UIFont systemFontOfSize:15];
}

- (UIFont*)fontForInterests
{
    return [UIFont systemFontOfSize:12];
}

@end
