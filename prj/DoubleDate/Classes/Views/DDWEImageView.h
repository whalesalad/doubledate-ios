//
//  DDWEImageView.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDImageView.h"
#import "WEPopoverParentView.h"

@protocol DDWEImageViewDelegate <NSObject>

- (CGRect)displayAreaForPopoverFromView:(UIView*)view;

@end

@interface DDWEImageView : DDImageView<WEPopoverParentView>
{
}

@property(nonatomic, assign) id<DDWEImageViewDelegate> popoverDelegate;

@end
