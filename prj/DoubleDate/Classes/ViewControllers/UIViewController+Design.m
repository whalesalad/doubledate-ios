//
//  UIViewController+Design.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 9/5/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "UIViewController+Design.h"
#import "DDBarButtonItem.h"
#import "DDTools.h"
#import "DDViewController.h"
#import "DDTableViewController.h"
#import <objc/message.h>
#import <QuartzCore/QuartzCore.h>

@implementation UIViewController (Design)

- (BOOL)isColorForKey:(NSString*)key
{
    return [key isEqualToString:@"UIColor"];
}

- (UIColor*)colorForValue:(NSObject*)value
{
    if ([value isKindOfClass:[NSString class]])
    {
        NSInteger r = 0, g = 0, b = 0, a = 0;
        sscanf([(NSString*)value cStringUsingEncoding:NSASCIIStringEncoding], [@"(%d,%d,%d,%d)" cStringUsingEncoding:NSASCIIStringEncoding], &r, &g, &b, &a);
        return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:(float)a/255.0f];
    }
    return nil;
}

- (BOOL)isFloatForKey:(NSString*)key
{
    return [key isEqualToString:@"CGFloat"] || [key isEqualToString:@"float"];
}

- (CGFloat)floatForValue:(NSObject*)value
{
    if ([value isKindOfClass:[NSNumber class]])
        return [(NSNumber*)value floatValue];
    return 0;
}

- (BOOL)isBoolForKey:(NSString*)key
{
    return [key isEqualToString:@"BOOL"] || [key isEqualToString:@"bool"];
}

- (BOOL)boolForValue:(NSObject*)value
{
    if ([value isKindOfClass:[NSNumber class]])
        return [(NSNumber*)value boolValue];
    return NO;
}

- (BOOL)isPointForKey:(NSString*)key
{
    return [key isEqualToString:@"CGPoint"];
}

- (CGPoint)pointForValue:(NSObject*)value
{
    if ([value isKindOfClass:[NSString class]])
    {
        NSInteger x = 0, y = 0;
        sscanf([(NSString*)value cStringUsingEncoding:NSASCIIStringEncoding], [@"(%d,%d)" cStringUsingEncoding:NSASCIIStringEncoding], &x, &y);
        return CGPointMake(x, y);
    }
    return CGPointZero;
}

- (BOOL)isSizeForKey:(NSString*)key
{
    return [key isEqualToString:@"CGSize"];
}

- (CGSize)sizeForValue:(NSObject*)value
{
    if ([value isKindOfClass:[NSString class]])
    {
        NSInteger w = 0, h = 0;
        sscanf([(NSString*)value cStringUsingEncoding:NSASCIIStringEncoding], [@"(%d,%d)" cStringUsingEncoding:NSASCIIStringEncoding], &w, &h);
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}

- (BOOL)isCGColorForKey:(NSString*)key
{
    return [key isEqualToString:@"CGColorRef"];
}

- (CGColorRef)CGColorForValue:(NSObject*)value
{
    return [self colorForValue:value].CGColor;
}

- (BOOL)isRectForKey:(NSString*)key
{
    return [key isEqualToString:@"CGRect"];
}

- (CGRect)rectForValue:(NSObject*)value
{
    if ([value isKindOfClass:[NSString class]])
    {
        NSInteger x = 0, y = 0, w = 0, h = 0;
        sscanf([(NSString*)value cStringUsingEncoding:NSASCIIStringEncoding], [@"(%d,%d,%d,%d)" cStringUsingEncoding:NSASCIIStringEncoding], &x, &y, &w, &h);
        return CGRectMake(x, y, w, h);
    }
    return CGRectZero;
}

- (BOOL)isEdgeInsetsForKey:(NSString*)key
{
    return [key isEqualToString:@"UIEdgeInsets"];
}

- (UIEdgeInsets)edgeInsetsForValue:(NSObject*)value
{
    if ([value isKindOfClass:[NSString class]])
    {
        NSInteger t = 0, l = 0, b = 0, r = 0;
        sscanf([(NSString*)value cStringUsingEncoding:NSASCIIStringEncoding], [@"(%d,%d,%d,%d)" cStringUsingEncoding:NSASCIIStringEncoding], &t, &l, &b, &r);
        return UIEdgeInsetsMake(t, l, b, r);
    }
    return UIEdgeInsetsZero;
}

- (void)applyKey:(NSString*)key forObject:(NSObject*)object fromDictionary:(NSDictionary*)dictionary
{
    //set special cases
    SEL separatedSelector = nil;
    NSString *param = nil;
        
    //check special cases
    if ([key rangeOfString:@":"].location != NSNotFound)
    {
        assert([[key componentsSeparatedByString:@":"] count] != 1);
        separatedSelector = NSSelectorFromString([[[key componentsSeparatedByString:@":"] objectAtIndex:0] stringByAppendingString:@":"]);
        param = [[key componentsSeparatedByString:@":"] objectAtIndex:1];
    }
    
    //try to get the selector
    SEL sel = NSSelectorFromString(key);
    if ([object respondsToSelector:sel] || [object respondsToSelector:separatedSelector])
    {
        //get dictionary object
        NSObject *dicObject = [dictionary objectForKey:key];
        
        //dictionary means getter
        if ([dicObject isKindOfClass:[NSDictionary class]])
        {
            //check if parameter inside
            BOOL parameterInside = NO;
            for (NSString *key in [(NSDictionary*)dicObject allKeys])
            {
                if ([self isColorForKey:key] || [self isFloatForKey:key] || [self isBoolForKey:key] || [self isPointForKey:key] || [self isSizeForKey:key] || [self isCGColorForKey:key] || [self isRectForKey:key] || [self isEdgeInsetsForKey:key])
                    parameterInside = YES;
            }
            
            //get child object only if not value
            NSObject *childObject = nil;
            if (!parameterInside)
            {
                if (!separatedSelector)
                    childObject = [object performSelector:sel];
                else
                {
                    //int parameter
                    if (separatedSelector == @selector(viewWithTag:))
                    {
                        childObject = objc_msgSend(object, separatedSelector, [param intValue]);
                    }
                }
            }
                
            //check if we have object to make an action
            if (childObject)
            {
                //enumerate all keys
                for (NSString *childKey in [[dictionary objectForKey:key] allKeys])
                    [self applyKey:childKey forObject:childObject fromDictionary:[dictionary objectForKey:key]];
            }
            else
            {
                //create setter string
                NSString *setterString = [NSString stringWithFormat:@"set%@%@:", [[key substringWithRange:NSMakeRange(0, 1)] capitalizedString], [key substringFromIndex:1]];
                
                //check if setter is exist with 1 parameter
                if ([object respondsToSelector:NSSelectorFromString(setterString)] && [[(NSDictionary*)dicObject allKeys] count] == 1)
                {
                    //get param
                    NSString *key = [[(NSDictionary*)dicObject allKeys] objectAtIndex:0];
                    NSObject *value = [(NSDictionary*)dicObject objectForKey:key];
                    
                    //check color
                    if ([self isColorForKey:key])
                        objc_msgSend(object, NSSelectorFromString(setterString), [self colorForValue:value]);
                    else if ([self isFloatForKey:key])
                    {
                        CGFloat v = [self floatForValue:value];
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:NSSelectorFromString(setterString)]];
                        invocation.selector = NSSelectorFromString(setterString);
                        invocation.target = object;
                        [invocation setArgument:&v atIndex:2];
                        [invocation invoke];
                    }
                    else if ([self isBoolForKey:key])
                    {
                        BOOL v = [self boolForValue:value];
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:NSSelectorFromString(setterString)]];
                        invocation.selector = NSSelectorFromString(setterString);
                        invocation.target = object;
                        [invocation setArgument:&v atIndex:2];
                        [invocation invoke];
                    }
                    else if ([self isPointForKey:key])
                    {
                        CGPoint v = [self pointForValue:value];
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:NSSelectorFromString(setterString)]];
                        invocation.selector = NSSelectorFromString(setterString);
                        invocation.target = object;
                        [invocation setArgument:&v atIndex:2];
                        [invocation invoke];
                    }
                    else if ([self isSizeForKey:key])
                    {
                        CGSize v = [self sizeForValue:value];
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:NSSelectorFromString(setterString)]];
                        invocation.selector = NSSelectorFromString(setterString);
                        invocation.target = object;
                        [invocation setArgument:&v atIndex:2];
                        [invocation invoke];
                    }
                    else if ([self isCGColorForKey:key])
                    {
                        CGColorRef v = [self CGColorForValue:value];
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:NSSelectorFromString(setterString)]];
                        invocation.selector = NSSelectorFromString(setterString);
                        invocation.target = object;
                        [invocation setArgument:&v atIndex:2];
                        [invocation invoke];
                    }
                    else if ([self isRectForKey:key])
                    {
                        CGRect v = [self rectForValue:value];
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:NSSelectorFromString(setterString)]];
                        invocation.selector = NSSelectorFromString(setterString);
                        invocation.target = object;
                        [invocation setArgument:&v atIndex:2];
                        [invocation invoke];
                    }
                    else if ([self isEdgeInsetsForKey:key])
                    {
                        UIEdgeInsets v = [self edgeInsetsForValue:value];
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:NSSelectorFromString(setterString)]];
                        invocation.selector = NSSelectorFromString(setterString);
                        invocation.target = object;
                        [invocation setArgument:&v atIndex:2];
                        [invocation invoke];
                    }
                }
            }
        }
    }
}

- (void)customizeViewWillAppear
{
    //load dictionay
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Design" ofType:@"plist"]];
    
    //read each class
    for (NSString *key in [dictionary allKeys])
    {
        //check class
        Class curClass = NSClassFromString(key);
        
        //check if class is self
        if (![self isKindOfClass:curClass])
            continue;
        
        //check if class is dictionary
        if ([[dictionary objectForKey:key] isKindOfClass:[NSDictionary class]])
        {
            for (NSString *childKey in [(NSDictionary*)[dictionary objectForKey:key] allKeys])
                [self applyKey:childKey forObject:self fromDictionary:(NSDictionary*)[dictionary objectForKey:key]];
        }
    }
}

- (void)customizeViewDidLoad
{
    //set background color
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dd-pinstripe-background"]];
    
    //check table view controller
    if ([self isKindOfClass:[UITableViewController class]])
    {
        //unset table view
        [[(UITableViewController*)self tableView] setBackgroundColor:[UIColor clearColor]];
        [[(UITableViewController*)self tableView] setBackgroundView:[[[UIImageView alloc] initWithImage:[DDTools clearImage]] autorelease]];
    }
    
    //customize navigation bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav-background.png"] forBarMetrics:UIBarMetricsDefault];
    
    //customize left button
    self.navigationItem.leftBarButtonItem = [DDBarButtonItem backBarButtonItemWithTitle:NSLocalizedString(@"Back", nil) target:self action:@selector(backTouched:)];
}

@end
