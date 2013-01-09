//
//  DDInvitationTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDInvitationTableViewCell.h"
#import "DDTools.h"

@implementation DDInvitationTableViewCell

@synthesize buttonAccept;
@synthesize buttonDeny;

- (void)awakeFromNib
{
    [super awakeFromNib];
#warning customize here
    [self.buttonAccept setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"accept-button.png"]] forState:UIControlStateNormal];
    [self.buttonDeny setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"deny-button.png"]] forState:UIControlStateNormal];
    DD_F_NAVIGATION_HEADER_MAIN(self.buttonDeny);
}

- (void)dealloc
{
    [buttonAccept release];
    [buttonDeny release];
    [super dealloc];
}

@end
