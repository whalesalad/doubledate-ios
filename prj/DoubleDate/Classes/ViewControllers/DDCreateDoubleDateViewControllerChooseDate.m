//
//  DDCreateDoubleDateViewControllerChooseDate.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 10/25/12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDCreateDoubleDateViewControllerChooseDate.h"
#import "DDDoubleDate.h"
#import "DDCreateDoubleDateViewController.h"

@interface DDCreateDoubleDateViewControllerChooseDate () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation DDCreateDoubleDateViewControllerChooseDate

@synthesize day;
@synthesize time;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.navigationItem.title = NSLocalizedString(@"When", nil);
    
    //add table view
    tableView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    tableView_.dataSource = self;
    tableView_.delegate = self;
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView_];
    tableView_.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noise_bg.png"]] autorelease];
}

- (void)viewDidUnload
{
    [tableView_ release], tableView_ = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [tableView_ release];
    [day release];
    [time release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (BOOL)isCellSelected:(UITableViewCell*)cell
{
    return cell.accessoryView != nil;
}

- (void)setCell:(UITableViewCell*)cell selected:(BOOL)selected
{
    if (selected)
        cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"approve-invite.png"]] autorelease];
    else
        cell.accessoryView = nil;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    //change selected state
    [self setCell:cell selected:![self isCellSelected:cell]];
    
    //update real values
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
            self.day = DDDoubleDateDayPrefWeekday;
        else if (indexPath.row == 1)
            self.day = DDDoubleDateDayPrefWeekend;
        if (![self isCellSelected:cell])
            self.day = nil;
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
            self.time = DDDoubleDateTimePrefDaytime;
        else if (indexPath.row == 1)
            self.time = DDDoubleDateTimePrefNighttime;
        if (![self isCellSelected:cell])
            self.time = nil;
    }
    else if (indexPath.section == 0)
    {
        self.day = nil;
        self.time = nil;
    }
    
    //inform delegate
    [self.delegate createDoubleDateViewControllerChooseDateUpdatedDayTime:self];
    
    //reload the table
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
        return 40;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 32)] autorelease];
        label.font = [UIFont systemFontOfSize:14];
        label.backgroundColor = [UIColor clearColor];
        label.contentMode = UIViewContentModeBottomLeft;
        label.text = NSLocalizedString(@"    Or, you can be more specific:", nil);
        return label;
    }
    return nil;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 2;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //create cell
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:[[UITableViewCell class] description]];
    if (!cell)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[UITableViewCell class] description]] autorelease];
            
    //apply data
    if (indexPath.section == 0)
    {
        cell.textLabel.text = [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:nil];
        [self setCell:cell selected:(self.day == nil) && (self.time == nil)];
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:DDDoubleDateDayPrefWeekday];
            [self setCell:cell selected:[self.day isEqualToString:DDDoubleDateDayPrefWeekday]];
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:DDDoubleDateDayPrefWeekend];
            [self setCell:cell selected:[self.day isEqualToString:DDDoubleDateDayPrefWeekend]];
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:DDDoubleDateTimePrefDaytime];
            [self setCell:cell selected:[self.time isEqualToString:DDDoubleDateTimePrefDaytime]];
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = [DDCreateDoubleDateViewController titleForDDDoubleDateProperty:DDDoubleDateTimePrefNighttime];
            [self setCell:cell selected:[self.time isEqualToString:DDDoubleDateTimePrefNighttime]];
        }
    }
    
    return cell;
}

@end
