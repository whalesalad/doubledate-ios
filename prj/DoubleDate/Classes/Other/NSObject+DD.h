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

#define DD_F_TEXT(_X_) [_X_ setFontOfName:@"HelveticaNeue" fontSize:14 textColor:[UIColor whiteColor] shadowOffset:CGSizeMake(0, 1) shadowColor:[UIColor grayColor]]
#define DD_F_PLACEHOLDER(_X_) [_X_ setFontOfName:@"HelveticaNeue" fontSize:14 textColor:[UIColor lightGrayColor] shadowOffset:CGSizeMake(0, 1) shadowColor:[UIColor blackColor]]

//#define DD_F_BUTTON(_X_) [_X_ setFontOfName:@"Avenir-Black" fontSize:14 textColor:[UIColor whiteColor] shadowOffset:CGSizeMake(0, 1) shadowColor:[UIColor grayColor]]
#define DD_F_BUTTON(_X_) [_X_ setFontOfName:@"Avenir-Black" fontSize:12 textColor:[UIColor whiteColor] shadowOffset:CGSizeMake(0, -1) shadowColor:[UIColor colorWithRed:156/255 green:20/255 blue:71/255 alpha:0.5]]

#define DD_F_TABLE_CELL_MAIN(_X_) [_X_ setFontOfName:@"Avenir-Black" fontSize:16 textColor:[UIColor whiteColor] shadowOffset:CGSizeMake(0, -1) shadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]]
#define DD_F_TABLE_CELL_DETAILED(_X_) [_X_ setFontOfName:@"HelveticaNeue" fontSize:13 textColor:[UIColor lightGrayColor] shadowOffset:CGSizeMake(0, -1) shadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]]

//#define DD_F_ICON_BUTTON_DETAILS(_X_) [_X_ setFontOfName:@"Avenir-Black" fontSize:12 textColor:[UIColor colorWithRed:70/255 green:70/255 blue:70/255 alpha:1.0] shadowOffset:CGSizeMake(0, -1) shadowColor:[UIColor colorWithRed:39/255 green:39/255 blue:39/255 alpha: 1.0]]
#define DD_F_ICON_BUTTON_DETAILS(_X_) [_X_ setFontOfName:@"Avenir-Black" fontSize:12 textColor:[UIColor darkGrayColor] shadowOffset:CGSizeMake(0, -1) shadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]]

#define DD_F_ICON_BUTTON_PLACEHOLDER(_X_) [_X_ setFontOfName:@"HelveticaNeue-Bold" fontSize:16 textColor:[UIColor grayColor] shadowOffset:CGSizeMake(0, -1) shadowColor:[UIColor blackColor]]
#define DD_F_ICON_BUTTON_TEXT(_X_) [_X_ setFontOfName:@"HelveticaNeue-Bold" fontSize:16 textColor:[UIColor whiteColor] shadowOffset:CGSizeMake(0, 1) shadowColor:[UIColor blackColor]]

// Start Michael's Stuff

//#define DD_F_ICON_TABLE_CELL_LABEL(_X_) [_X_ setFontOfName:@"Avenir-Black" fontSize:12 textColor:[UIColor darkGrayColor] shadowOffset:CGSizeMake(0, -1) shadowColor:[UIColor blackColor]]

- (void)setFontOfName:(NSString*)fontName fontSize:(CGFloat)fontSize textColor:(UIColor*)textColor shadowOffset:(CGSize)shadowOffset shadowColor:(UIColor*)shadowColor;

@end