//
//  DDInvitationTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDWingTableViewCell.h"

@interface DDInvitationTableViewCell : DDWingTableViewCell
{
}

@property(nonatomic, retain) IBOutlet UIButton *buttonAccept;
@property(nonatomic, retain) IBOutlet UIButton *buttonDeny;

@end
