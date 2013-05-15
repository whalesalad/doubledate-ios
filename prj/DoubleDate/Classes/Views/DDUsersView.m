//
//  DDUsersView.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 12/24/12.
//  Copyright (c) 2012-2013 Belluba. All rights reserved.
//

#import "DDUsersView.h"
#import "DDShortUser.h"
#import "DDUser.h"
#import "DDImageView.h"
#import "DDImage.h"
#import "UIImageView+WebCache.h"
#import "DWGridView.h"
#import <QuartzCore/QuartzCore.h>

#define kMovingTimeMin 3.0f
#define kMovingTimeMax 5.0f

#define kExtraItems 3

@interface DDUsersViewCellParam : NSObject

@property(nonatomic, assign) DWPosition position;
@property(nonatomic, assign) CGFloat speed;

@end

@implementation DDUsersViewCellParam

@synthesize position;
@synthesize speed;

@end

@interface DDUsersViewCell : DWGridViewCell

@property(nonatomic, retain) UIImageView *imageView;
@property(nonatomic, assign) DWPosition position;

@end

@implementation DDUsersViewCell

@synthesize imageView;
@synthesize position;

- (void)dealloc
{
    [imageView release];
    [super dealloc];
}

@end

@interface DWGridView (Hidden)

-(void)moveCellAtPosition:(DWPosition)position horizontallyBy:(CGFloat)velocity withTranslation:(CGPoint)translation reloadingData:(BOOL)shouldReload;

@end

@interface DDUsersView ()<DWGridViewDataSource, DWGridViewDelegate>

@property(nonatomic, retain) DWGridView *grid;
@property(nonatomic, retain) NSMutableArray *cells;

@end

@implementation DDUsersView

@synthesize users;

@synthesize grid;
@synthesize cells;

- (DDUsersViewCell*)addCellInPosition:(DWPosition)position
{
    //create view
    DDUsersViewCell *cell = [[[DDUsersViewCell alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/columns_, self.frame.size.height/rows_)] autorelease];
    
    //add image view
    cell.imageView = [[[UIImageView alloc] initWithFrame:cell.bounds] autorelease];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell addSubview:cell.imageView];
    
    //set position
    cell.position = position;
    
    //add cell
    [self.cells addObject:cell];
    
    return cell;
}

- (DDUsersViewCell*)existCellInPosition:(DWPosition)position
{
    //get normalized position
    position = [self.grid normalizePosition:position];
    
    //return needed cell
    for (DDUsersViewCell *cell in self.cells)
    {
        if (cell.position.row == position.row && cell.position.column == position.column)
            return cell;
    }
    return nil;
}

- (id)initWithFrame:(CGRect)frame rows:(NSInteger)rows columns:(NSInteger)columns
{
    if ((self = [super initWithFrame:frame]))
    {
        //set parameters
        rows_ = rows;
        columns_ = columns;
        
        //create grid
        self.grid = [[[DWGridView alloc] initWithFrame:self.bounds] autorelease];
        self.grid.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.grid];
        self.grid.clipsToBounds = YES;
        self.grid.delegate = self;
        self.grid.dataSource = self;
        
        //create cells
        self.cells = [NSMutableArray array];
        for (int i = 0; i < rows + kExtraItems; i++)
        {
            for (int j = 0; j < columns + kExtraItems; j++)
            {
                //set position
                DWPosition position;
                position.row = i;
                position.column = j;
                
                //add cell
                [self addCellInPosition:position];
            }
        }
        
        //start animating
        [self startAnimation];
    }
    return self;
}

- (NSURL*)randomUrl
{
    NSObject *randomUser = nil;
    if ([self.users count] > 1)
        randomUser = [self.users objectAtIndex:rand()%[self.users count]];
    else
        randomUser = [self.users lastObject];
    if ([randomUser isKindOfClass:[DDUser class]])
        return [NSURL URLWithString:[[(DDUser*)randomUser photo] thumbUrl]];
    else if ([randomUser isKindOfClass:[DDShortUser class]])
        return [NSURL URLWithString:[[(DDShortUser*)randomUser photo] thumbUrl]];
    return nil;
}

- (void)setUsers:(NSArray *)v
{
    //check for value
    if (users != v)
    {
        //update value
        [users release];
        users = [v retain];
        
        //set random url
        for (DDUsersViewCell *cell in self.cells)
            [cell.imageView setImageWithURL:[self randomUrl]];
    }
}

- (void)animateWithParam:(DDUsersViewCellParam*)param
{
    [UIView animateWithDuration:param.speed
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.grid moveCellAtPosition:param.position horizontallyBy:0 withTranslation:CGPointMake(self.frame.size.width/columns_*(param.position.row%2?1:-1), 0) reloadingData:NO];
    } completion:^(BOOL finished) {
        if (self.superview)
        {
            [self.grid reloadData];
            [self animateWithParam:param];
        }
    }];
}

- (void)startAnimation
{
    for (int i = 0; i < rows_; i++)
    {
        DWPosition position;
        position.row = i;
        position.column = 0;
        DDUsersViewCellParam *param = [[[DDUsersViewCellParam alloc] init] autorelease];
        param.position = position;
        param.speed = kMovingTimeMin + (kMovingTimeMax - kMovingTimeMin) * (rand()%100) / 100.0f;
        [self animateWithParam:param];
    }
}

- (void)dealloc
{
    [users release];
    [cells release];
    [grid stop];
    [grid release];
    [super dealloc];
}

#pragma mark -
#pragma DWGridViewDataSource

- (NSInteger)numberOfRowsInGridView:(DWGridView *)gridView
{
    return rows_ + kExtraItems;
}

- (NSInteger)numberOfColumnsInGridView:(DWGridView *)gridView
{
    return columns_ + kExtraItems;
}

- (NSInteger)numberOfVisibleRowsInGridView:(DWGridView *)gridView
{
    return rows_;
}

- (NSInteger)numberOfVisibleColumnsInGridView:(DWGridView *)gridView
{
    return columns_;
}

#pragma mark -
#pragma DWGridViewDelegate

- (DWGridViewCell *)gridView:(DWGridView *)gridView cellAtPosition:(DWPosition)position
{
    DWGridViewCell *cell = [self existCellInPosition:position];
    return cell?cell:[self addCellInPosition:position];
}

-(BOOL)gridView:(DWGridView *)gridView shouldScrollCell:(DWGridViewCell *)cell atPosition:(DWPosition)position
{
    return YES;
}

-(void)gridView:(DWGridView *)gridView willMoveCell:(DWGridViewCell *)cell fromPosition:(DWPosition)fromPosition toPosition:(DWPosition)toPosition
{
}

-(void)gridView:(DWGridView *)gridView didMoveCell:(DWGridViewCell *)cell fromPosition:(DWPosition)fromPosition toPosition:(DWPosition)toPosition
{
    //moving vertically
    toPosition = [gridView normalizePosition:toPosition];
    if (toPosition.column == fromPosition.column)
    {
        //How many places is the tile moved (can be negative!)
        NSInteger amount = toPosition.row - fromPosition.row;
        DDUsersViewCell *cellDict = [self existCellInPosition:fromPosition];
        DDUsersViewCell *toCell;
        do
        {
            //Get the next cell
            toCell = [self existCellInPosition:toPosition];
            
            //update the current cell
            DWPosition position = cellDict.position;
            position.row = toPosition.row;
            cellDict.position = position;
            
            //prepare the next cell
            cellDict = toCell;
            
            //calculate the next position
            toPosition.row += amount;
            
            toPosition = [gridView normalizePosition:toPosition];
        } while (toCell);
    }
    else //moving horizontally
    {
        //How many places is the tile moved (can be negative!)
        NSInteger amount = toPosition.column - fromPosition.column;
        DDUsersViewCell *cellDict = [self existCellInPosition:fromPosition];
        DDUsersViewCell *toCell;
        do
        {
            //Get the next cell
            toCell = [self existCellInPosition:toPosition];
            
            //update the current cell
            DWPosition position = cellDict.position;
            position.column = toPosition.column;
            cellDict.position = position;
            
            //prepare the next cell
            cellDict = toCell;
            
            //calculate the next position
            toPosition.column += amount;
            toPosition = [gridView normalizePosition:toPosition];
        } while (toCell);
        
    }
}

@end
