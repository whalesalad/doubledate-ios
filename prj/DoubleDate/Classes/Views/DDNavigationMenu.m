//
//  DDNavigationMenu.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 2/5/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDNavigationMenu.h"
#import "DDNavigationMenuTableViewCell.h"
#import "DDAppDelegate.h"

@interface DDNavigationMenu () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation DDNavigationMenu

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 5 * [DDNavigationMenuTableViewCell height])];
    if (self)
    {
#warning customize navigation menu
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav-bg.png"]];
        self.separatorColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        self.delegate = self;
        self.dataSource = self;
        self.scrollEnabled = NO;
    }
    return self;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DDNavigationMenuTableViewCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDAppDelegate *appDelegate = (DDAppDelegate*)[[UIApplication sharedApplication] delegate];
    UITabBarController *tabBarController = nil;
    if ([appDelegate.viewController isKindOfClass:[UINavigationController class]])
    {
        NSArray *viewControllers = [(UINavigationController*)appDelegate.viewController viewControllers];
        for (UITabBarController *c in viewControllers)
        {
            if ([c isKindOfClass:[UITabBarController class]] && [viewControllers indexOfObject:c] == 1)
                tabBarController = c;
        }
    }
    if (indexPath.row < [tabBarController.viewControllers count])
        tabBarController.selectedIndex = indexPath.row;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //save class
    Class cellClass = [DDNavigationMenuTableViewCell class];
    
    //create cell
    DDNavigationMenuTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:[cellClass description]];
    if (!cell)
        cell = [[[UINib nibWithNibName:[cellClass description] bundle:nil] instantiateWithOwner:aTableView options:nil] objectAtIndex:0];
    
    //save center of the icon
    CGPoint iconCenter = cell.imageViewIcon.center;
    
    switch (indexPath.row) {
        case 0:
            cell.imageViewIcon.image = [UIImage imageNamed:@"nav-icon-notifications.png"];
            cell.labelTitle.text = NSLocalizedString(@"Notifications", nil);
            cell.labelBadge.text = @"3";
            break;
        case 1:
            cell.imageViewIcon.image = [UIImage imageNamed:@"nav-icon-profile.png"];
            cell.labelTitle.text = NSLocalizedString(@"Profile", nil);
            cell.labelBadge.text = @"0";
            break;
        case 2:
            cell.imageViewIcon.image = [UIImage imageNamed:@"nav-icon-wings.png"];
            cell.labelTitle.text = NSLocalizedString(@"Wings", nil);
            cell.labelBadge.text = @"1";
            break;
        case 3:
            cell.imageViewIcon.image = [UIImage imageNamed:@"nav-icon-doubledates.png"];
            cell.labelTitle.text = NSLocalizedString(@"DoubleDates", nil);
            cell.labelBadge.text = @"0";
            break;
        case 4:
            cell.imageViewIcon.image = [UIImage imageNamed:@"nav-icon-messages.png"];
            cell.labelTitle.text = NSLocalizedString(@"Messages", nil);
            cell.labelBadge.text = @"2";
            break;
        default:
            break;
    }
    
    //hide badge image view if no text
    cell.imageViewBadge.hidden = [cell.labelBadge.text intValue] == 0;
    cell.labelBadge.hidden = cell.imageViewBadge.hidden;
    
    //restore center of the icon
    cell.imageViewIcon.frame = CGRectMake(0, 0, cell.imageViewIcon.image.size.width, cell.imageViewIcon.image.size.height);
    cell.imageViewIcon.center = iconCenter;
    
    return cell;
}

@end
