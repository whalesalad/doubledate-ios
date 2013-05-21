//
//  FBWebDialogs+DD.h
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FBWebDialogs (DD)

+ (void)presentRequestsDialogModallyWithSession:(FBSession *)session
                                        message:(NSString *)message
                                          title:(NSString *)title
                                          users:(NSArray *)users
                                        handler:(FBWebDialogHandler)handler;

@end
