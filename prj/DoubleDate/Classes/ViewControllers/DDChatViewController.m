//
//  DDChatViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 1/17/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDChatViewController.h"
#import "DDChatTableViewCell.h"
#import "DDDoubleDate.h"
#import "DDEngagement.h"
#import "DDMessage.h"
#import "DDImageView.h"
#import "DDShortUser.h"
#import "DDUser.h"
#import "DDuserBubble.h"
#import "DDAppDelegate+UserBubble.h"
#import "DDTools.h"
#import "DDTextView.h"
#import "DDAuthenticationController.h"
#import "HPGrowingTextView.h"
#import "DDObjectsController.h"
#import "DDDoubleDateViewController.h"
#import "DDBarButtonItem.h"
#import <QuartzCore/QuartzCore.h>

#define kTagUnlockAlert 213
#define kUnlockCost 50

@interface DDChatViewController ()<UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, HPGrowingTextViewDelegate>

@property(nonatomic, retain) UIView *popover;

- (void)presentPopoverWithUser:(DDShortUser*)user;

@end

@implementation DDChatViewController

@synthesize popover;

@synthesize parentViewController;

@synthesize doubleDate;
@synthesize engagement;

@synthesize mainView;
@synthesize topBarView;
@synthesize bottomBarView;
@synthesize textViewInput;
@synthesize buttonSend;
@synthesize tableView;

@synthesize imageViewUser1;
@synthesize imageViewUser2;
@synthesize imageViewUser3;
@synthesize imageViewUser4;

@synthesize labelUser1;
@synthesize labelUser2;
@synthesize labelUser3;
@synthesize labelUser4;

@synthesize imageViewChatBarBackground;
@synthesize imageViewTextFieldBackground;

@synthesize labelTextFieldPlaceholder;
@synthesize labelWarning;

@synthesize viewLocked;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChangeNotification:) name:UITextViewTextDidChangeNotification object:nil];
        shortUsers_ = [[NSMutableArray alloc] init];
        users_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"%@ & %@", nil), self.engagement.user.firstName, self.engagement.wing.firstName];
    
    //don't show layer under the status bar
    self.view.layer.masksToBounds = YES;
    
    //set header
    {
        //add header view
        UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)] autorelease];
        self.tableView.tableHeaderView = headerView;
        
        //add button
        UIButton *buttonHeader = [[[UIButton alloc] initWithFrame:CGRectMake(10, 12, 300, 36)] autorelease];
        [buttonHeader setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"upper-chat-button.png"]] forState:UIControlStateNormal];
        [buttonHeader setTitle:NSLocalizedString(@"View DoubleDate", nil) forState:UIControlStateNormal];
        [headerView addSubview:buttonHeader];
        [buttonHeader addTarget:self action:@selector(doubleDateTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        buttonHeader.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f];
        [buttonHeader setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [buttonHeader setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.3f] forState:UIControlStateNormal];
        [buttonHeader.titleLabel setShadowOffset:CGSizeMake(0, -1)];
        
        //add label
        UILabel *labelHeader = [[[UILabel alloc] initWithFrame:CGRectMake(0, 48, 320, 32)] autorelease];
        labelHeader.backgroundColor = [UIColor clearColor];
        labelHeader.textAlignment = NSTextAlignmentCenter;
        
        DD_F_CHAT_TIMESTAMP_LABEL(labelHeader);
        
        NSDate *date = [DDTools dateFromString:[self.engagement createdAt]];
        NSDateFormatter *dateFormatterTo = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatterTo setDateFormat:@"MMMM dd 'at' hh:mma"];
        labelHeader.text = [dateFormatterTo stringFromDate:date];
        [headerView addSubview:labelHeader];
    }
    
    //unset backgrounds
    self.mainView.backgroundColor = [UIColor clearColor];
    self.topBarView.backgroundColor = [UIColor clearColor];
    self.bottomBarView.backgroundColor = [UIColor clearColor];
    self.textViewInput.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.labelUser1.backgroundColor = [UIColor clearColor];
    self.labelUser2.backgroundColor = [UIColor clearColor];
    self.labelUser3.backgroundColor = [UIColor clearColor];
    self.labelUser4.backgroundColor = [UIColor clearColor];
    
    //don't show text out of the box
    self.textViewInput.layer.masksToBounds = YES;
    self.textViewInput.contentInset = UIEdgeInsetsZero;
    
    //set background for text view
    imageViewTextFieldBackground.image = [DDTools resizableImageFromImage:[UIImage imageNamed:@"bg-textfield.png"]];
    
    //set placeholder
    self.labelTextFieldPlaceholder.text = NSLocalizedString(@"Reply...", nil);
    
    //set background for chat bar
    self.imageViewChatBarBackground.image = [DDTools resizableImageFromImage:[UIImage imageNamed:@"bg-chatbar.png"]];
    
    //customize send button
    [self.buttonSend setBackgroundImage:[DDTools resizableImageFromImage:[UIImage imageNamed:@"button-send.png"]] forState:UIControlStateNormal];
    
    //add users
    [shortUsers_ removeAllObjects];
    [shortUsers_ addObject:self.doubleDate.user];
    [shortUsers_ addObject:self.doubleDate.wing];
    [shortUsers_ addObject:self.engagement.user];
    [shortUsers_ addObject:self.engagement.wing];
    
    //apply photos
    NSArray *tempImageViews = [NSArray arrayWithObjects:self.imageViewUser1, self.imageViewUser2, self.imageViewUser3, self.imageViewUser4, nil];
    for (int i = 0; i < 4; i++)
    {
        DDImageView *imageView = [tempImageViews objectAtIndex:i];
        NSString *url = [[(DDShortUser*)[shortUsers_ objectAtIndex:i] photo] smallUrl];
        if (url)
            [imageView reloadFromUrl:[NSURL URLWithString:url]];
    }
    
    //apply labels
    NSArray *tempLabels = [NSArray arrayWithObjects:self.labelUser1, self.labelUser2, self.labelUser3, self.labelUser4, nil];
    for (int i = 0; i < 4; i++)
    {
        UILabel *label = [tempLabels objectAtIndex:i];
        [label setText:[[(DDShortUser*)[shortUsers_ objectAtIndex:i] firstName] uppercaseString]];
    }
    
    //load users
    for (DDShortUser *shortUser in shortUsers_)
    {
        DDUser *requestUser = [[[DDUser alloc] init] autorelease];
        requestUser.userId = shortUser.identifier;
        [self.apiController getUser:requestUser];
    }
    
    //set warning
    self.labelWarning.text = [NSString stringWithFormat:NSLocalizedString(@"You have %d days to chat!", nil), 10];
    
    //customize text view
    self.textViewInput.delegate = self;
    self.textViewInput.maxNumberOfLines = [DDTools isiPhone5Device]?16:10;
    
    self.textViewInput.textColor = [UIColor colorWithRed:34.0f/255.0f green:34.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
    self.textViewInput.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    
    //this is hack - simulate 2 lines string and roll back
    self.textViewInput.animateHeightChange = NO;
    self.textViewInput.text = @"XXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
    self.textViewInput.text = @"";
    self.textViewInput.animateHeightChange = YES;
    
    //request new messages anyways
    DDRequestId requestId = [self.apiController getMessagesForEngagement:self.engagement];
    NSString *requestPath = [self.apiController pathForRequest:requestId];
    
    //load cache for path
    [messages_ release];
    messages_ = [[NSMutableArray alloc] initWithArray:[DDObjectsController cachedObjectsOfClass:[DDMessage class] forPath:requestPath]];
    
    //reload the table
    [self.tableView reloadData];
    
    //check if you are the owner of engagement
    self.viewLocked.hidden = YES;
    if (([[self.engagement.user identifier] intValue] == [[[DDAuthenticationController currentUser] userId] intValue]) ||
        ([[self.engagement.wing identifier] intValue] == [[[DDAuthenticationController currentUser] userId] intValue]))
    {
        //check if we need to unlock the engagement
        if ([self.engagement.status isEqualToString:DDEngagementStatusLocked])
        {
            //make bottom bar opaque
            self.bottomBarView.alpha = 0.2f;
            self.labelWarning.hidden = YES;
            
            //put unlocked overlay
            self.viewLocked.hidden = NO;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //scroll to bottom
    if ([messages_ count] && !alreadyAppeared_)
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messages_ count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    //save that view already appeared
    alreadyAppeared_ = YES;
}

#pragma mark -
#pragma mark Keyboard

- (void)keyboardDidShow:(NSNotification*)notification
{
    //save keyboard
    keyboardExist_ = YES;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    //scroll table view to bottom
    if ([messages_ count] > 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messages_ count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    //save tab bar height
    CGFloat tabBarHeight = self.weakParentViewController.tabBarController.tabBar.hidden?0:self.weakParentViewController.tabBarController.tabBar.frame.size.height;
    
    //animate
    [UIView beginAnimations:@"DDChatViewControllerKeyboardAnimation" context:nil];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    CGRect rect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat dh = rect.size.height - tabBarHeight;
    self.mainView.frame = CGRectMake(self.mainView.frame.origin.x, self.mainView.frame.origin.y-dh, self.mainView.frame.size.width, self.mainView.frame.size.height);
    [UIView commitAnimations];
}

- (void)keyboardDidHide:(NSNotification*)notification
{
    //save keyboard
    keyboardExist_ = NO;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    //save tab bar height
    CGFloat tabBarHeight = self.weakParentViewController.tabBarController.tabBar.hidden?0:self.weakParentViewController.tabBarController.tabBar.frame.size.height;
    
    //animate
    [UIView beginAnimations:@"DDChatViewControllerKeyboardAnimation" context:nil];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    CGRect rect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat dh = rect.size.height - tabBarHeight;
    self.mainView.frame = CGRectMake(self.mainView.frame.origin.x, self.mainView.frame.origin.y+dh, self.mainView.frame.size.width, self.mainView.frame.size.height);
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [popover release];
    [shortUsers_ release];
    [users_ release];
    [messages_ release];
    [doubleDate release];
    [engagement release];
    [mainView release];
    [topBarView release];
    [bottomBarView release];
    [textViewInput release];
    [buttonSend release];
    [tableView release];
    [imageViewUser1 release];
    [imageViewUser2 release];
    [imageViewUser3 release];
    [imageViewUser4 release];
    [labelUser1 release];
    [labelUser2 release];
    [labelUser3 release];
    [labelUser4 release];
    [imageViewChatBarBackground release];
    [imageViewTextFieldBackground release];
    [labelTextFieldPlaceholder release];
    [labelWarning release];
    [viewLocked release];
    [super dealloc];
}

#pragma mark -
#pragma mark IB

- (IBAction)sendTouched:(id)sender
{
    //check if you are the owner of doubledate
    if ([self.doubleDate.relationship isEqualToString:DDDoubleDateRelationshipOwner] ||
        [self.doubleDate.relationship isEqualToString:DDDoubleDateRelationshipWing])
    {
        //check if we need to unlock the engagement
        if ([engagement.status isEqualToString:DDEngagementStatusLocked])
        {
            //set format
            NSString *format = NSLocalizedString(@"It costs %d coins to start the conversation with %@ and %@.", nil);
            
            //create alert view
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:format, kUnlockCost, [engagement.user.firstName capitalizedString], [engagement.wing.firstName capitalizedString]] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Okay, Send!", nil), nil] autorelease];
            alert.tag = kTagUnlockAlert;
            [alert show];
            
            return;
        }
    }
    
    //send message
    if ([self.textViewInput.text length])
    {
        DDMessage *message = [[[DDMessage alloc] init] autorelease];
        message.message = self.textViewInput.text;
        [self.apiController createMessage:message forEngagement:self.engagement];
    }
    
    //unset text
    self.textViewInput.text = nil;
    
    //hide keyboard
    [self.textViewInput resignFirstResponder];
}

- (IBAction)user1Touched:(id)sender
{
    [self presentPopoverWithUser:[shortUsers_ objectAtIndex:0]];
}

- (IBAction)user2Touched:(id)sender
{
    [self presentPopoverWithUser:[shortUsers_ objectAtIndex:1]];
}

- (IBAction)user3Touched:(id)sender
{
    [self presentPopoverWithUser:[shortUsers_ objectAtIndex:2]];
}

- (IBAction)user4Touched:(id)sender
{
    [self presentPopoverWithUser:[shortUsers_ objectAtIndex:3]];
}

- (void)doubleDateTouched:(id)sender
{
    //open view controller
    DDDoubleDateViewController *viewController = [[[DDDoubleDateViewController alloc] init] autorelease];
    viewController.doubleDate = self.doubleDate;
    viewController.backButtonTitle = self.navigationItem.title;
    
    //wrap into navigation controller
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    [self.navigationController presentViewController:navigationController animated:YES completion:^{
    }];
    
    //set back button
    viewController.navigationItem.leftBarButtonItem = [DDBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Close", nil) target:self action:@selector(cancelDoubleDateTouched:)];
}

- (void)cancelDoubleDateTouched:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark -
#pragma mark other

- (DDUser*)userForShortUser:(DDShortUser*)shortUser
{
    for (DDUser *u in users_)
    {
        if ([[u userId] intValue] == [[shortUser identifier] intValue])
            return u;
    }
    return nil;
}

- (void)presentPopoverWithUser:(DDShortUser*)user
{
    //select needed user
    DDUser *userToSelect = [self userForShortUser:user];
    if (!userToSelect)
        return;
    
    //save users
    NSMutableArray *usersInBubble = [NSMutableArray array];
    for (DDShortUser *shortUser in shortUsers_)
    {
        DDUser *u = [self userForShortUser:shortUser];
        if (u)
            [usersInBubble addObject:u];
    }
    
    //present user bubble
    [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] presentUserBubbleForUser:userToSelect fromUsers:usersInBubble];
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewTextDidChangeNotification:(NSNotification *)notification
{
    //    //check senderf
    //    if ([notification object] != self.textViewInput)
    //        return;
    //
    //    //show/hide placeholder
    //    self.labelTextFieldPlaceholder.hidden = [self.textViewInput.text length] > 0;
    //
    //    //save needed values
    //    CGSize sizeBefore = self.textViewInput.frame.size;
    //    CGSize sizeAfter = self.textViewInput.contentSize;
    //
    //    //save maximal value
    //    CGFloat maximalHeight = self.bottomBarView.frame.origin.y + self.bottomBarView.frame.size.height - (self.topBarView.frame.origin.y + self.topBarView.frame.size.height) + self.mainView.frame.origin.y + 40;
    //
    //    //check for maximal size
    //    sizeAfter = CGSizeMake(sizeAfter.width, MIN(sizeAfter.height, maximalHeight));
    //
    //    //calculate frame change
    //    CGSize sizeChange = CGSizeMake(sizeAfter.width - sizeBefore.width, sizeAfter.height - sizeBefore.height);
    //
    //    //change frame
    //    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width + sizeChange.width, self.tableView.frame.size.height - sizeChange.height);
    //
    //    self.bottomBarView.frame = CGRectMake(self.bottomBarView.frame.origin.x - sizeChange.width, self.bottomBarView.frame.origin.y - sizeChange.height, bottomBarView.frame.size.width + sizeChange.width, bottomBarView.frame.size.height + sizeChange.height);
    //
    //    //apply frame to text view background
    //    self.imageViewTextFieldBackground.frame = self.textViewInput.frame;
}

#pragma mark -
#pragma mark HPGrowingTextViewDelegate

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    //show/hide placeholder
    self.labelTextFieldPlaceholder.hidden = [growingTextView.text length] > 0;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    //save size
    CGSize sizeChange = CGSizeMake(0, height - growingTextView.frame.size.height);
    
    //change frame
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width + sizeChange.width, self.tableView.frame.size.height - sizeChange.height);
    
    self.bottomBarView.frame = CGRectMake(self.bottomBarView.frame.origin.x - sizeChange.width, self.bottomBarView.frame.origin.y - sizeChange.height, bottomBarView.frame.size.width + sizeChange.width, bottomBarView.frame.size.height + sizeChange.height);
    
    //apply frame to text view background
//    self.imageViewTextFieldBackground.frame = self.textViewInput.frame;
    
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DDChatTableViewCell heightForText:[(DDMessage*)[messages_ objectAtIndex:indexPath.row] message]];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (keyboardExist_ && scrollView.dragging)
        [self.textViewInput resignFirstResponder];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [messages_ count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set identifier
    NSString *cellIdentifier = NSStringFromClass([DDChatTableViewCell class]);
    
    //create cell if needed
    DDChatTableViewCell *tableViewCell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!tableViewCell)
    {
        tableViewCell = [[[UINib nibWithNibName:cellIdentifier bundle:nil] instantiateWithOwner:aTableView options:nil] objectAtIndex:0];
    }
    
    //save message
    DDMessage *message = (DDMessage*)[messages_ objectAtIndex:indexPath.row];
    
    //apply message
    tableViewCell.message = message;
    
    //apply style
    tableViewCell.style = ([[message userId] intValue] == [self.doubleDate.wing.identifier intValue]) || ([[message userId] intValue] == [self.doubleDate.user.identifier intValue]);
    
    return tableViewCell;
}

#pragma mark -
#pragma mark API

- (void)getMessagesForEngagementSucceed:(NSArray*)messages
{
    //reload messages
    [messages_ release];
    messages_ = [[NSMutableArray alloc] initWithArray:messages];
    
    //reload the table
    [self.tableView reloadData];
    
    //scroll top top
    if ([messages_ count] > 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messages_ count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)getMessagesForEngagementDidFailedWithError:(NSError*)error
{
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)createMessageSucceed:(DDMessage*)message
{
    //reload messages
    [messages_ addObject:message];
    
    //reload the table
    [self.tableView reloadData];
    
    //scroll top top
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messages_ count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)createMessageDidFailedWithError:(NSError*)error
{
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

- (void)getUserDidSucceed:(DDUser*)u
{
    //add sliently
    [users_ addObject:u];
}

- (void)getUserDidFailedWithError:(NSError*)error
{
}

- (void)unlockEngagementSucceed:(DDEngagement*)e
{
    //hide hud
    [self hideHud:YES];
    
    //update obejct
    self.engagement = e;
    
    //replay send button
    [self sendTouched:nil];
}

- (void)unlockEngagementDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //check for invitation error
    if (alertView.tag == kTagUnlockAlert)
    {
        //check needed action
        if (buttonIndex == 0)
            ;
        else
        {
            //show loading
            [self showHudWithText:NSLocalizedString(@"Unlocking...", nil) animated:YES];
            
            //send request
            [self.apiController unlockEngagement:self.engagement];
        }
    }
}

@end
