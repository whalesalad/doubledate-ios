//
//  FBWebDialogs+DD.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/17/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "FBWebDialogs+DD.h"
#import "DDShortUser.h"
#import "DDUser.h"

@implementation FBWebDialogs (DD)

+ (void)presentRequestsDialogModallyWithSession:(FBSession *)session
                                        message:(NSString *)message
                                          title:(NSString *)title
                                          users:(NSArray *)users
                                        handler:(FBWebDialogHandler)handler
{
    //set fb ids
    NSMutableArray *fbIdsString = [NSMutableArray array];
    for (NSObject *user in users)
    {
        if ([user isKindOfClass:[DDUser class]])
        {
            DDUser *ddUser = (DDUser*)user;
            if ([ddUser facebookId])
                [fbIdsString addObject:[NSString stringWithFormat:@"%d", [ddUser.facebookId intValue]]];
        }
        else if ([user isKindOfClass:[DDShortUser class]])
        {
            DDShortUser *ddUser = (DDShortUser*)user;
            if ([ddUser facebookId])
                [fbIdsString addObject:[NSString stringWithFormat:@"%d", [ddUser.facebookId intValue]]];
        }
    }
    
    //save users id
    NSMutableString *fbidsString = [NSMutableString string];
    for (NSString *userId in fbIdsString)
    {
        [fbidsString appendString:userId];
        if (userId != [fbIdsString lastObject])
            [fbidsString appendString:@","];
    }
    
    //set parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   fbidsString, @"to", nil];
    //show dialog
    [FBWebDialogs presentRequestsDialogModallyWithSession:session
                                                  message:message
                                                    title:title
                                               parameters:params
                                                  handler:handler];
}

@end
