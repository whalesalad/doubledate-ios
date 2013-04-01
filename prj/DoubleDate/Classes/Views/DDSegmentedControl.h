//
//  DDSegmentedControl.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    DDSegmentedControlStyleSmall,
    DDSegmentedControlStyleLarge,
} DDSegmentedControlStyle;

@interface DDSegmentedControlItem : NSObject
{
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) CGFloat width;

+ (id)itemWithTitle:(NSString*)title;
+ (id)itemWithTitle:(NSString*)title width:(CGFloat)width;

@end

@interface DDSegmentedControl : UISegmentedControl
{
    NSMutableArray *items_;
}

- (id)initWithItems:(NSArray *)items style:(DDSegmentedControlStyle)style;

@end
