//
//  DDTextView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDTextView : UIView
{
    UITextView *textView_;
    UILabel *label_;
    NSString *placeholder_;
}

@property(nonatomic, readonly) UITextView *textView;

@property(nonatomic, retain) UIFont *font;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSString *placeholder;

@end
