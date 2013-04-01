//
//  DDDialog.m
//  DoubleDate
//
//  Created by Gennadii Ivanov 
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDDialog.h"

@implementation DDDialog

@synthesize slug;
@synthesize userId;
@synthesize coins;
@synthesize upperText;
@synthesize description;
@synthesize confirmText;
@synthesize confirmUrl;
@synthesize dismissText;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if ((self = [super initWithDictionary:dictionary]))
    {
        self.slug = [DDAPIObject stringForObject:[dictionary objectForKey:@"slug"]];
        self.userId = [DDAPIObject numberForObject:[dictionary objectForKey:@"user_id"]];
        self.coins = [DDAPIObject numberForObject:[dictionary objectForKey:@"coins"]];
        self.upperText = [DDAPIObject stringForObject:[dictionary objectForKey:@"upper_text"]];
        self.description = [DDAPIObject stringForObject:[dictionary objectForKey:@"description"]];
        self.confirmText = [DDAPIObject stringForObject:[dictionary objectForKey:@"confirm_text"]];
        self.confirmUrl = [DDAPIObject stringForObject:[dictionary objectForKey:@"confirm_url"]];
        self.dismissText = [DDAPIObject stringForObject:[dictionary objectForKey:@"dismiss_text"]];
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.slug)
        [dictionary setObject:self.slug forKey:@"slug"];
    if (self.userId)
        [dictionary setObject:self.userId forKey:@"user_id"];
    if (self.coins)
        [dictionary setObject:self.coins forKey:@"coins"];
    if (self.upperText)
        [dictionary setObject:self.upperText forKey:@"upper_text"];
    if (self.description)
        [dictionary setObject:self.description forKey:@"description"];
    if (self.confirmText)
        [dictionary setObject:self.confirmText forKey:@"confirm_text"];
    if (self.confirmUrl)
        [dictionary setObject:self.confirmUrl forKey:@"confirm_url"];
    if (self.dismissText)
        [dictionary setObject:self.dismissText forKey:@"dismiss_text"];
    return dictionary;
}

- (void)dealloc
{
    [slug release];
    [userId release];
    [coins release];
    [upperText release];
    [description release];
    [confirmText release];
    [confirmUrl release];
    [dismissText release];
    [super dealloc];
}

@end
