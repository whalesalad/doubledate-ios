//
//  DDSearchBar
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDSearchBar : UISearchBar
{
}

@property(nonatomic, assign) UIEdgeInsets inset;

- (UITextField*)textField;
- (UIButton*)button;

@end
