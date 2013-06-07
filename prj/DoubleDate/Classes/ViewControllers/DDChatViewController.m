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
#import "DDUserBubble.h"
#import "DDAppDelegate+UserBubble.h"
#import "DDTools.h"
#import "DDTextView.h"
#import "DDAuthenticationController.h"
#import "HPGrowingTextView.h"
#import "DDObjectsController.h"
#import "DDDoubleDateViewController.h"
#import "DDBarButtonItem.h"
#import "DDUnlockAlertView.h"
#import "DDEngagementsViewController.h"
#import "DDAppDelegate+NavigationMenu.h"
#import "UIImage+DD.h"
#import <QuartzCore/QuartzCore.h>

#define kTagUnlockAlert 213
#define kUnlockCost 50

#define kTagProposeActionSheet 532
#define kTagConfirmActionSheet 533

@interface DDChatViewController ()<UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, HPGrowingTextViewDelegate, DDUnlockAlertViewDelegate, UIActionSheetDelegate>

@property(nonatomic, retain) UIView *popover;

- (void)presentPopoverWithUser:(DDShortUser*)user;
//- (void)updateLockedView;

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

@synthesize viewLocked;

@synthesize labelMessageReceived;

@synthesize viewBottomLocked;
@synthesize buttonIgnore;
@synthesize buttonStartChat;
@synthesize labelLocked;

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
    
    //localize
    labelTextFieldPlaceholder.text = NSLocalizedString(@"Reply…", nil);
    [buttonSend setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    labelMessageReceived.text = NSLocalizedString(@"Message received. We'll let you know when they reply.", nil);
    
    //check if authenticated user is in activity
    BOOL authenticatedUserIsInActivity = [[[DDAuthenticationController currentUser] userId] intValue] == [[[self.engagement activityUser] identifier] intValue] || [[[DDAuthenticationController currentUser] userId] intValue] == [[[self.engagement activityWing] identifier] intValue];
    DDShortUser *userToShow = authenticatedUserIsInActivity?self.engagement.user:self.engagement.activityUser;
    DDShortUser *wingToShow = authenticatedUserIsInActivity?self.engagement.wing:self.engagement.activityWing;
    
    //set navigation title
    self.navigationItem.title = [NSString stringWithFormat:@"%@ & %@", userToShow.firstName, wingToShow.firstName];
    
    //don't show layer under the status bar
    self.view.layer.masksToBounds = YES;
    
    //set header
    {
        //add header view
        UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)] autorelease];
        self.tableView.tableHeaderView = headerView;
        
        //add button
        UIButton *buttonHeader = [[[UIButton alloc] initWithFrame:CGRectMake(10, 12, 300, 36)] autorelease];
        [buttonHeader setBackgroundImage:[[UIImage imageNamed:@"upper-chat-button.png"] resizableImage] forState:UIControlStateNormal];
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
        
        labelHeader.text = [DDTools stringFromDate:[DDTools dateFromString:[self.engagement createdAt]]];
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
    imageViewTextFieldBackground.image = [[UIImage imageNamed:@"bg-textfield.png"] resizableImage];
    
    //set placeholder
    self.labelTextFieldPlaceholder.text = NSLocalizedString(@"Reply…", nil);
    
    //set background for chat bar
    self.imageViewChatBarBackground.image = [[UIImage imageNamed:@"bg-chatbar.png"] resizableImage];
    
    //customize send button
    [self.buttonSend setBackgroundImage:[[UIImage imageNamed:@"button-send.png"] resizableImage] forState:UIControlStateNormal];
    
    //customize buttons
    [self.buttonIgnore setBackgroundImage:[[self.buttonIgnore backgroundImageForState:UIControlStateNormal] resizableImage] forState:UIControlStateNormal];
    [self.buttonStartChat setBackgroundImage:[[self.buttonStartChat backgroundImageForState:UIControlStateNormal] resizableImage] forState:UIControlStateNormal];
    [self.buttonStartChat setBackgroundImage:[[self.buttonStartChat backgroundImageForState:UIControlStateDisabled] resizableImage] forState:UIControlStateDisabled];
    
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
        NSString *url = [[(DDShortUser*)[shortUsers_ objectAtIndex:i] photo] thumbUrl];
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
    
    self.viewBottomLocked.hidden = YES;
    
    // Check if you are the owner of engagement
    self.viewLocked.hidden = YES;
    
    if (([[self.engagement.user identifier] intValue] == [[[DDAuthenticationController currentUser] userId] intValue]) ||
        ([[self.engagement.wing identifier] intValue] == [[[DDAuthenticationController currentUser] userId] intValue]))
    {
        //check if we need to unlock the engagement
        if ([self.engagement isNew])
        {
            //make bottom bar opaque
            self.bottomBarView.alpha = 0.2f;
            
            //put unlocked overlay
            self.viewLocked.hidden = NO;
        }
    }
    
    //add end chat functionality
    if ([[[DDAuthenticationController currentUser] userId] intValue] == [self.doubleDate.user.identifier intValue] ||
        [[[DDAuthenticationController currentUser] userId] intValue] == [self.engagement.user.identifier intValue])
    {
        self.navigationItem.rightBarButtonItem = [DDBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"button-gear.png"] target:self action:@selector(editTouched:)];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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

- (void)editTouched:(id)sender
{
    [(DDAppDelegate*)[[UIApplication sharedApplication] delegate] dismissNavigationMenu];
    
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"End Chat", nil), nil] autorelease];
    actionSheet.tag = kTagProposeActionSheet;
    [actionSheet showInView:self.view];
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
    [viewLocked release];
    [labelMessageReceived release];
    [viewBottomLocked release];
    [buttonIgnore release];
    [buttonStartChat release];
    [labelLocked release];
    [super dealloc];
}

#pragma mark -
#pragma mark IB

- (IBAction)sendTouched:(id)sender
{
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

- (IBAction)ignoreTouched:(id)sender
{
    [self stopChatWithMessage:NSLocalizedString(@"Are you sure you want to stop this chat?", @"Stopping chat from ignore button")];
}

- (IBAction)startChatTouched:(id)sender
{
    //add full-screen alert
    DDUnlockAlertViewFullScreen *alertView = [[[DDUnlockAlertViewFullScreen alloc] init] autorelease];
    alertView.unlockButtonText = NSLocalizedString(@"Yes, Start", @"Unlock engagement dialog confirm button text");
    alertView.delegate = self;
    alertView.title = NSLocalizedString(@"START CHAT", @"Unlock engagement dialog title.");
    alertView.price = kUnlockCost;
    alertView.message = [NSString stringWithFormat:NSLocalizedString(@"Would you like to start\nthis chat for %d coins?", @"Unlock engagement dialog message text"), kUnlockCost];
    [alertView show];
}

- (void)stopChatWithMessage:(NSString*)message
{
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Yes", @"Confirm chat stop button in action sheet"), nil] autorelease];
    actionSheet.tag = kTagConfirmActionSheet;
    [actionSheet showInView:self.view];
}

- (void)stopChat
{
    //show hud
    [self showHudWithText:NSLocalizedString(@"Deleting…", @"Deleting engagement on chat page") animated:YES];
    
    //request delete engagement
    [self.apiController requestDeleteEngagement:self.engagement];
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

- (NSString*)engagementsKey
{
    return @"engagements";
}

- (NSDictionary*)saveEngagementsDictionary
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:[self engagementsKey]];
}

- (NSString*)engagementKey
{
    return [NSString stringWithFormat:@"%d_%d", [self.engagement.identifier intValue], [self.engagement.daysRemaining intValue]];
}

- (NSDictionary*)engagementDictionary
{
    return [[self saveEngagementsDictionary] objectForKey:[self engagementKey]];
}

- (NSString*)shownKey
{
    return @"shown";
}

- (NSString*)hiddenKey
{
    return @"hidden";
}

//- (void)updateLockedView
//{
//    //save locked/expired flags
//    BOOL started_and_date_owners = NO;
//    
//    //save flags
//    started_and_date_owners = engagement.isStarted && ([self.doubleDate.relationship isEqualToString:DDDoubleDateRelationshipOwner] ||
//                                                       [self.doubleDate.relationship isEqualToString:DDDoubleDateRelationshipWing]);
//    
//    //switch between different titles
//    if (locked)
//    {
//        [self.buttonIgnore setTitle:NSLocalizedString(@"Ignore", nil) forState:UIControlStateNormal];
//        [self.buttonStartChat setTitle:NSLocalizedString(@"Start Chat", nil) forState:UIControlStateNormal];
//        [self.labelLocked setText:NSLocalizedString(@"This chat hasn't started yet.", @"Chat page locked label while engagement is locked")];
//    }
//    else
//    {
//        [self.buttonIgnore setTitle:nil forState:UIControlStateNormal];
//        [self.buttonStartChat setTitle:nil forState:UIControlStateNormal];
//        [self.labelLocked setText:nil];
//    }
//    
//    //update locked view
//    CAGradientLayer *bottomLockedGradient = [CAGradientLayer layer];
//    bottomLockedGradient.frame = self.viewBottomLocked.bounds;
//    bottomLockedGradient.colors = [NSArray arrayWithObjects: (id)[[UIColor colorWithRed:77/255.0f green:77/255.0f blue:77/255.0f alpha:1.0f] CGColor],
//                                                             (id)[[UIColor colorWithRed:44/255.0f green:44/255.0f blue:44/255.0f alpha:1.0f] CGColor], nil];
//
//    [self.viewBottomLocked.layer insertSublayer:bottomLockedGradient atIndex:0];
//    
//    CALayer *bottomLockedUpperLine = [CALayer layer];
//    CGRect bottomLockedUpperLineFrame = self.viewBottomLocked.bounds;
//    bottomLockedUpperLineFrame.size.height = 1.0f;
//    bottomLockedUpperLine.frame = bottomLockedUpperLineFrame;
//    bottomLockedUpperLine.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.15f].CGColor;
//    
//    viewBottomLocked.layer.shadowRadius = 2.0f;
//    viewBottomLocked.layer.shadowColor = [UIColor blackColor].CGColor;
//    viewBottomLocked.layer.shadowOpacity = 0.5f;
//    viewBottomLocked.layer.shadowOffset = CGSizeMake(0, -1);
//    
//    // Add the border to the scrollview
//    [self.viewBottomLocked.layer insertSublayer:bottomLockedUpperLine atIndex:1];
//    
//    //hide/show locked view
//    self.viewBottomLocked.hidden = !(locked || expired);
//    
//    //change frame accordingly
//    if (!self.viewBottomLocked.hidden) {
//        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
//        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 55, 0);
//    } else {
//        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
//        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
//    }
//    
//}

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
    
    //update total coins
    NSInteger totalCoins = [[[DDAuthenticationController currentUser] totalCoins] intValue] - kUnlockCost;
    [[DDAuthenticationController currentUser] setTotalCoins:[NSNumber numberWithInt:totalCoins]];
    
    //inform about change
    [[NSNotificationCenter defaultCenter] postNotificationName:DDObjectsControllerDidUpdateObjectNotification object:[DDAuthenticationController currentUser]];
    
    // update locked view
    // [self updateLockedView];
    
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

- (void)requestDeleteEngagementSucceed
{
    //hide hud
    [self hideHud:YES];
    
    //show completed hud
    [self showCompletedHudWithText:NSLocalizedString(@"Done", @"Complete message after deleting chat view")];
    
    //remove from previous view controller
    if ([self.weakParentViewController isKindOfClass:[DDEngagementsViewController class]])
        [(DDEngagementsViewController*)self.weakParentViewController removeEngagement:self.engagement];
    
    //go back
    if (self.navigationController.presentedViewController == self)
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
        }];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)requestDeleteEngagementDidFailedWithError:(NSError*)error
{
    //hide hud
    [self hideHud:YES];
    
    //show error
    [[[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma mark DDUnlockAlertViewDelegate

- (void)unlockAlertViewDidUnlock:(DDUnlockAlertView*)sender
{
    //show loading
    [self showHudWithText:NSLocalizedString(@"Unlocking", nil) animated:YES];
    
    //send request
    [self.apiController unlockEngagement:self.engagement];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //check end chat butto
    if (actionSheet.tag == kTagProposeActionSheet)
    {
        if (buttonIndex == 0)
            [self stopChatWithMessage:NSLocalizedString(@"Are you sure you want to end this chat?", @"Stopping chat from gear button")];
    }
    else if (actionSheet.tag == kTagConfirmActionSheet)
    {
        if (buttonIndex == 0)
            [self stopChat];
    }
}

@end
