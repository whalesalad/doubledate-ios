//
//  DDFacebookController.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBSession;

@interface DDFacebookController : NSObject
{
    FBSession *session_;
}

+ (DDFacebookController*)sharedController;

- (void)login;

@end
