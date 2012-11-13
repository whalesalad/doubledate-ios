//
//  DDSegmentedControl.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    DDSegmentedControlStyleRedBar,
    DDSegmentedControlStyleBlackLarge,
} DDSegmentedControlStyle;

@interface DDSegmentedControl : UISegmentedControl
{
    NSMutableArray *items_;
}

- (id)initWithItems:(NSArray *)items style:(DDSegmentedControlStyle)style;

@end
