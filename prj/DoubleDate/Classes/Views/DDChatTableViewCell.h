//
//  DDChatTableViewCell.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 1/18/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDTableViewCell.h"

@class DDMessage;

typedef enum
{
    DDChatTableViewCellStyleMeNotMe,
    DDChatTableViewCellStyleMe
} DDChatTableViewCellStyle;

@interface DDChatTableViewCell : DDTableViewCell
{
    CGFloat rightPositionOfLastLabel_;
    CGFloat labelsGap_;
}

@property(nonatomic, retain) IBOutlet UITextView *textView;
@property(nonatomic, retain) IBOutlet UIImageView *imageViewBubble;
@property(nonatomic, retain) IBOutlet UILabel *labelTime;
@property(nonatomic, retain) IBOutlet UILabel *labelName;

@property(nonatomic, retain) DDMessage *message;

@property(nonatomic, assign) DDChatTableViewCellStyle style;

+ (CGFloat)heightForText:(NSString*)text;

@end
