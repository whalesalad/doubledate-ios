//
//  DDDoubleDateFilterViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 14.11.12.
//  Copyright (c) 2012 Gennadii Ivanov. All rights reserved.
//

#import "DDDoubleDateFilterViewController.h"
#import "DDTools.h"
#import "DDButton.h"
#import "DDBarButtonItem.h"
#import "DDDoubleDateFilter.h"

@interface DDDoubleDateFilterViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>

- (void)updateArrowForButton:(UIButton*)button;
- (NSString*)objectForIndex:(NSInteger)index fromArray:(NSArray*)array;
- (NSObject*)keyForIndex:(NSInteger)index fromArray:(NSArray*)array;
- (NSArray*)arrayForPicker:(UIPickerView*)picker;
- (UITextField*)textFieldForPicker:(UIPickerView*)picker;
- (void)updateNavigationButton;
- (UISegmentedControl*)segmentedControlSort;
- (UISegmentedControl*)segmentedControlWhen;

@end

@implementation DDDoubleDateFilterViewController

@synthesize delegate;

@synthesize labelSort;
@synthesize viewSortContainer;
@synthesize labelWhen;
@synthesize viewWhenContainer;
@synthesize labelDistance;
@synthesize viewDistanceContainer;
@synthesize labelMinAge;
@synthesize viewMinAgeContainer;
@synthesize labelMaxAge;
@synthesize viewMaxAgeContainer;

- (id)initWithFilter:(DDDoubleDateFilter*)filter
{
    self = [super init];
    if (self)
    {
        //save filter
        filter_ = [filter retain];

        //fill data
        distances_ = [[NSMutableArray alloc] init];
        [distances_ addObject:[NSDictionary dictionaryWithObject:NSLocalizedString(@"WITHIN 5 MILES OF ME", nil) forKey:@"5mi"]];
        [distances_ addObject:[NSDictionary dictionaryWithObject:NSLocalizedString(@"WITHIN 10 MILES OF ME", nil) forKey:@"10mi"]];
        [distances_ addObject:[NSDictionary dictionaryWithObject:NSLocalizedString(@"WITHIN 50 MILES OF ME", nil) forKey:@"50mi"]];
        [distances_ addObject:[NSDictionary dictionaryWithObject:NSLocalizedString(@"WITHIN 100 MILES OF ME", nil) forKey:@"100mi"]];
        
        //fill data
        minAges_ = [[NSMutableArray alloc] init];
        [minAges_ addObject:[NSDictionary dictionaryWithObject:NSLocalizedString(@"20 YEARS", nil) forKey:[NSNumber numberWithInt:20]]];
        [minAges_ addObject:[NSDictionary dictionaryWithObject:NSLocalizedString(@"25 YEARS", nil) forKey:[NSNumber numberWithInt:25]]];
        [minAges_ addObject:[NSDictionary dictionaryWithObject:NSLocalizedString(@"30 YEARS", nil) forKey:[NSNumber numberWithInt:30]]];
        
        //fill data
        maxAges_ = [[NSMutableArray alloc] init];
        [maxAges_ addObject:[NSDictionary dictionaryWithObject:NSLocalizedString(@"20 YEARS", nil) forKey:[NSNumber numberWithInt:20]]];
        [maxAges_ addObject:[NSDictionary dictionaryWithObject:NSLocalizedString(@"25 YEARS", nil) forKey:[NSNumber numberWithInt:25]]];
        [maxAges_ addObject:[NSDictionary dictionaryWithObject:NSLocalizedString(@"30 YEARS", nil) forKey:[NSNumber numberWithInt:30]]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Filter & Sort", nil);
    
    //set right button
    self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Apply", nil) target:self action:@selector(applyTouched:)];
    
    //set left button
    self.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Cancel", nil) target:self action:@selector(cancelTouched:)];
    
#define ADD_PICKER_FIELD_TO_BUTTON(_FIELD_, _ARRAY_, _DEF_)\
    {\
        _FIELD_ = [[UITextField alloc] initWithFrame:CGRectZero];\
        _FIELD_.text = [self objectForIndex:_DEF_ fromArray:_ARRAY_];\
        [button addSubview:_FIELD_];\
        UIPickerView *pickerView = [[[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)] autorelease];\
        pickerView.dataSource = self;\
        pickerView.delegate = self;\
        pickerView.showsSelectionIndicator = YES;\
        _FIELD_.inputView = pickerView;\
        [pickerView selectRow:_DEF_ inComponent:0 animated:NO];\
    }
    
    //unset parameters
    self.labelSort.backgroundColor = [UIColor clearColor];
    DD_F_HEADER_MAIN(self.labelSort);
    self.viewSortContainer.backgroundColor = [UIColor clearColor];
    self.labelWhen.backgroundColor = [UIColor clearColor];
    DD_F_HEADER_MAIN(self.labelWhen);
    self.viewWhenContainer.backgroundColor = [UIColor clearColor];
    self.labelDistance.backgroundColor = [UIColor clearColor];
    DD_F_HEADER_MAIN(self.labelDistance);
    self.viewDistanceContainer.backgroundColor = [UIColor clearColor];
    self.labelMinAge.backgroundColor = [UIColor clearColor];
    DD_F_HEADER_MAIN(self.labelMinAge);
    self.viewMinAgeContainer.backgroundColor = [UIColor clearColor];
    self.labelMaxAge.backgroundColor = [UIColor clearColor];
    DD_F_HEADER_MAIN(self.labelMaxAge);
    self.viewMaxAgeContainer.backgroundColor = [UIColor clearColor];
    
    {
        //add sort segmented control
        NSInteger itemWidth = self.viewSortContainer.frame.size.width/3;
        NSMutableArray *items = [NSMutableArray array];
        [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"CLOSEST", nil) width:itemWidth]];
        [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"NEWEST", nil) width:itemWidth]];
        [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"OLDEST", nil) width:itemWidth]];
        DDSegmentedControl *segmentedControl = [[[DDSegmentedControl alloc] initWithItems:items style:DDSegmentedControlStyleLarge] autorelease];
        segmentedControl.frame = CGRectMake(0, 0, self.viewSortContainer.frame.size.width, self.viewSortContainer.frame.size.height);
        [self.viewSortContainer addSubview:segmentedControl];
        [segmentedControl addTarget:self action:@selector(updateNavigationButton) forControlEvents:UIControlEventValueChanged];
        
        //set default value
        if (filter_ && [filter_.sort isEqualToString:DDDoubleDateFilterSortClosest])
            segmentedControl.selectedSegmentIndex = 0;
        if (filter_ && [filter_.sort isEqualToString:DDDoubleDateFilterSortNewest])
            segmentedControl.selectedSegmentIndex = 1;
        if (filter_ && [filter_.sort isEqualToString:DDDoubleDateFilterSortOldest])
            segmentedControl.selectedSegmentIndex = 2;
    }
    
    {
        //add when segmented control
        NSInteger itemWidth = self.viewWhenContainer.frame.size.width/3;
        NSMutableArray *items = [NSMutableArray array];
        [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"ANYTIME", nil) width:itemWidth]];
        [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"WEEKDAY", nil) width:itemWidth]];
        [items addObject:[DDSegmentedControlItem itemWithTitle:NSLocalizedString(@"WEEKEND", nil) width:itemWidth]];
        DDSegmentedControl *segmentedControl = [[[DDSegmentedControl alloc] initWithItems:items style:DDSegmentedControlStyleLarge] autorelease];
        segmentedControl.frame = CGRectMake(0, 0, self.viewWhenContainer.frame.size.width, self.viewWhenContainer.frame.size.height);
        [self.viewWhenContainer addSubview:segmentedControl];
        [segmentedControl addTarget:self action:@selector(updateNavigationButton) forControlEvents:UIControlEventValueChanged];
        
        //set default value
        segmentedControl.selectedSegmentIndex = 0;
        if (filter_ && [filter_.happening isEqualToString:DDDoubleDateFilterHappeningWeekday])
            segmentedControl.selectedSegmentIndex = 1;
        if (filter_ && [filter_.happening isEqualToString:DDDoubleDateFilterHappeningWeekend])
            segmentedControl.selectedSegmentIndex = 2;
    }
    
    //add button
    {
        //set selected index
        NSInteger selectedindex = 0;
        for (int i = 0; i < [distances_ count]; i++)
        {
            if (filter_ && [filter_.distance isEqualToString:[self objectForIndex:i fromArray:distances_]])
                selectedindex = i;
        }
        
        //add button
        UIButton *button = [DDToggleButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, self.viewDistanceContainer.frame.size.width, self.viewDistanceContainer.frame.size.height);
        [button setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"large-button.png"]] forState:UIControlStateNormal];
        [button setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"large-button-highlight.png"]] forState:UIControlStateHighlighted];
        DD_F_BUTTON_LARGE(button);
        [button setTitle:[self objectForIndex:selectedindex fromArray:distances_] forState:UIControlStateNormal];
        [self.viewDistanceContainer addSubview:button];
        
        //update arrow
        [self updateArrowForButton:button];
        
        //add handler
        [button addTarget:self action:@selector(distanceTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        ADD_PICKER_FIELD_TO_BUTTON(textFieldDistance_, distances_, selectedindex);
    }
    
    //add button
    {
        //set selected index
        NSInteger selectedindex = 1;
        for (int i = 0; i < [minAges_ count]; i++)
        {
            if (filter_ && ([filter_.minAge intValue] == [[self objectForIndex:i fromArray:minAges_] intValue]))
                selectedindex = i;
        }
        
        //add button
        UIButton *button = [DDToggleButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, self.viewMinAgeContainer.frame.size.width, self.viewMinAgeContainer.frame.size.height);
        [button setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"large-button.png"]] forState:UIControlStateNormal];
        [button setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"large-button-highlight.png"]] forState:UIControlStateHighlighted];
        DD_F_BUTTON_LARGE(button);
        [button setTitle:[self objectForIndex:selectedindex fromArray:minAges_] forState:UIControlStateNormal];
        [self.viewMinAgeContainer addSubview:button];
        
        //update arrow
        [self updateArrowForButton:button];
        
        //add handler
        [button addTarget:self action:@selector(minAgeTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        ADD_PICKER_FIELD_TO_BUTTON(textFieldMinAge_, minAges_, selectedindex);
    }
    
    //add button
    {
        //set selected index
        NSInteger selectedindex = 2;
        for (int i = 0; i < [maxAges_ count]; i++)
        {
            if (filter_ && ([filter_.maxAge intValue] == [[self objectForIndex:i fromArray:maxAges_] intValue]))
                selectedindex = i;
        }
        
        //add button
        UIButton *button = [DDToggleButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, self.viewMaxAgeContainer.frame.size.width, self.viewMaxAgeContainer.frame.size.height);
        [button setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"large-button.png"]] forState:UIControlStateNormal];
        [button setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"large-button-highlight.png"]] forState:UIControlStateHighlighted];
        DD_F_BUTTON_LARGE(button);
        [button setTitle:[self objectForIndex:selectedindex fromArray:maxAges_] forState:UIControlStateNormal];
        [self.viewMaxAgeContainer addSubview:button];
        
        //update arrow
        [self updateArrowForButton:button];
        
        //add handler
        [button addTarget:self action:@selector(maxAgeTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        ADD_PICKER_FIELD_TO_BUTTON(textFieldMaxAge_, maxAges_, selectedindex);
    }
    
    //update navigation button
    [self updateNavigationButton];
}

- (void)dealloc
{
    [filter_ release];
    [distances_ release];
    [minAges_ release];
    [maxAges_ release];
    [textFieldDistance_ release];
    [textFieldMinAge_ release];
    [textFieldMaxAge_ release];
    [labelSort release];
    [viewSortContainer release];
    [labelWhen release];
    [viewWhenContainer release];
    [labelDistance release];
    [viewDistanceContainer release];
    [labelMinAge release];
    [viewMinAgeContainer release];
    [labelMaxAge release];
    [viewMaxAgeContainer release];
    [super dealloc];
}

#pragma mark -
#pragma mark other

- (void)updateArrowForButton:(UIButton *)button
{
    UIImageView *imageView = nil;
    for (UIImageView *iv in [button.superview subviews])
    {
        if ([iv isKindOfClass:[UIImageView class]])
            imageView = iv;
    }
    if (!imageView)
    {
        imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"large-button-down-arrow.png"]] autorelease];
        [button.superview addSubview:imageView];
    }
    imageView.center = CGPointMake(button.frame.size.width/2 + [[button titleForState:UIControlStateNormal] sizeWithFont:[button titleLabel].font].width/2 + 12, button.frame.size.height/2-2);
}

- (NSString*)objectForIndex:(NSInteger)index fromArray:(NSArray*)array
{
    NSDictionary *dictionary = [array objectAtIndex:index];
    return [dictionary objectForKey:[[dictionary allKeys] lastObject]];
}

- (NSObject*)keyForIndex:(NSInteger)index fromArray:(NSArray*)array
{
    NSDictionary *dictionary = [array objectAtIndex:index];
    return [[dictionary allKeys] lastObject];
}

- (NSArray*)arrayForPicker:(UIPickerView*)picker
{
    if (picker == textFieldDistance_.inputView)
        return distances_;
    if (picker == textFieldMinAge_.inputView)
        return minAges_;
    if (picker == textFieldMaxAge_.inputView)
        return maxAges_;
    return nil;
}

- (UITextField*)textFieldForPicker:(UIPickerView*)picker
{
    if (picker == textFieldDistance_.inputView)
        return textFieldDistance_;
    if (picker == textFieldMinAge_.inputView)
        return textFieldMinAge_;
    if (picker == textFieldMaxAge_.inputView)
        return textFieldMaxAge_;
    return nil;
}

- (void)distanceTouched:(DDToggleButton*)button
{
    if (button.toggled)
        [textFieldDistance_ becomeFirstResponder];
    else
        [textFieldDistance_ resignFirstResponder];
}

- (void)minAgeTouched:(DDToggleButton*)button
{
    if (button.toggled)
        [textFieldMinAge_ becomeFirstResponder];
    else
        [textFieldMinAge_ resignFirstResponder];
}

- (void)maxAgeTouched:(DDToggleButton*)button
{
    if (button.toggled)
        [textFieldMaxAge_ becomeFirstResponder];
    else
        [textFieldMaxAge_ resignFirstResponder];
}

- (void)updateNavigationButton
{
    self.navigationItem.rightBarButtonItem.enabled = [textFieldMinAge_.text intValue] <= [textFieldMaxAge_.text intValue] && [self segmentedControlSort].selectedSegmentIndex >= 0;
}

- (void)applyTouched:(id)sender
{
    DDDoubleDateFilter *filter = [[[DDDoubleDateFilter alloc] init] autorelease];
    switch ([self.segmentedControlSort selectedSegmentIndex]) {
        case 0:
            filter.sort = DDDoubleDateFilterSortClosest;
            break;
        case 1:
            filter.sort = DDDoubleDateFilterSortNewest;
            break;
        case 2:
            filter.sort = DDDoubleDateFilterSortOldest;
            break;
        default:
            break;
    }
    switch ([self.segmentedControlWhen selectedSegmentIndex]) {
        case 0:
            filter.happening = nil;
            break;
        case 1:
            filter.happening = DDDoubleDateFilterHappeningWeekday;
            break;
        case 2:
            filter.happening = DDDoubleDateFilterHappeningWeekend;
            break;
        default:
            break;
    }
    filter.minAge = [NSNumber numberWithInt:[[textFieldMinAge_ text] intValue]];
    filter.maxAge = [NSNumber numberWithInt:[[textFieldMaxAge_ text] intValue]];
    for (NSDictionary *dic in distances_)
    {
        NSString *key = [[dic allKeys] lastObject];
        if ([[dic objectForKey:key] isEqualToString:[textFieldDistance_ text]])
            filter.distance = key;
    }
    [self.delegate doubleDateFilterViewControllerDidAppliedFilter:filter];
}

- (void)cancelTouched:(id)sender
{
    [self.delegate doubleDateFilterViewControllerDidCancel];
}

- (UISegmentedControl*)segmentedControlSort
{
    for (UISegmentedControl *v in [self.viewSortContainer subviews])
    {
        if ([v isKindOfClass:[UISegmentedControl class]])
            return v;
    }
    return nil;
}

- (UISegmentedControl*)segmentedControlWhen
{
    for (UISegmentedControl *v in [self.viewWhenContainer subviews])
    {
        if ([v isKindOfClass:[UISegmentedControl class]])
            return v;
    }
    return nil;
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[self arrayForPicker:pickerView] count];
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self objectForIndex:row fromArray:[self arrayForPicker:thePickerView]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UITextField *textField = [self textFieldForPicker:pickerView];
    [textField setText:[self objectForIndex:row fromArray:[self arrayForPicker:pickerView]]];
    [textField resignFirstResponder];
    [(DDToggleButton*)[textField superview] setToggled:NO];
    [(DDToggleButton*)[textField superview] setTitle:textField.text forState:UIControlStateNormal];
    [self updateArrowForButton:(DDToggleButton*)[textField superview]];
    [self updateNavigationButton];
}

@end
