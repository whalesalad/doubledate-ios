//
//  NSObject+DD.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSObject (DD)

#define DD_F_HEADER_MAIN(_X_) [_X_ setFontOfName:@"Avenir-Black" fontSize:14 textColor:[UIColor grayColor] shadowOffset:CGSizeMake(0, 1) shadowColor:[UIColor whiteColor]]
#define DD_F_HEADER_DETAILED(_X_) [_X_ setFontOfName:@"Avenir" fontSize:11 textColor:[UIColor grayColor] shadowOffset:CGSizeMake(0, 1) shadowColor:[UIColor whiteColor]]

#define DD_F_TEXT(_X_) [_X_ setFontOfName:@"Avenir-Black" fontSize:14 textColor:[UIColor whiteColor] shadowOffset:CGSizeMake(0, 1) shadowColor:[UIColor grayColor]]

#define DD_F_PLACEHOLDER(_X_) [_X_ setFontOfName:@"Avenir-Black" fontSize:14 textColor:[UIColor grayColor] shadowOffset:CGSizeMake(0, 1) shadowColor:[UIColor whiteColor]]

#define DD_F_BUTTON(_X_) [_X_ setFontOfName:@"Avenir-Black" fontSize:14 textColor:[UIColor whiteColor] shadowOffset:CGSizeMake(0, 1) shadowColor:[UIColor grayColor]]

#define DD_F_TABLE_CELL_MAIN(_X_) [_X_ setFontOfName:@"Avenir-Black" fontSize:18 textColor:[UIColor whiteColor] shadowOffset:CGSizeMake(0, 1) shadowColor:[UIColor grayColor]]
#define DD_F_TABLE_CELL_DETAILED(_X_) [_X_ setFontOfName:@"Avenir-Black" fontSize:14 textColor:[UIColor grayColor] shadowOffset:CGSizeMake(0, 1) shadowColor:[UIColor whiteColor]]

#define DD_F_ICON_BUTTON_DETAILS(_X_) [_X_ setFontOfName:@"Avenir-Black" fontSize:12 textColor:[[UIColor grayColor] colorWithAlphaComponent:0.5f] shadowOffset:CGSizeMake(0, 0) shadowColor:[UIColor whiteColor]]
#define DD_F_ICON_BUTTON_TEXT(_X_) [_X_ setFontOfName:@"Avenir-Black" fontSize:16 textColor:[UIColor whiteColor] shadowOffset:CGSizeMake(0, 0) shadowColor:[UIColor whiteColor]]
#define DD_F_ICON_BUTTON_PLACEHOLDER(_X_) [_X_ setFontOfName:@"Avenir-Black" fontSize:16 textColor:[UIColor grayColor] shadowOffset:CGSizeMake(0, 0) shadowColor:[UIColor whiteColor]]

- (void)setFontOfName:(NSString*)fontName fontSize:(CGFloat)fontSize textColor:(UIColor*)textColor shadowOffset:(CGSize)shadowOffset shadowColor:(UIColor*)shadowColor;

@end