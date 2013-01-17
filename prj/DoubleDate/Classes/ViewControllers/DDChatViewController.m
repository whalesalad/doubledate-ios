//
//  DDChatViewController.m
//  DoubleDate
//
//  Created by Gennadii Ivanov on 1/17/13.
//  Copyright (c) 2013 Gennadii Ivanov. All rights reserved.
//

#import "DDChatViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DDChatViewController ()<UITextViewDelegate>

@end

@implementation DDChatViewController

@synthesize parentViewController;

@synthesize mainView;
@synthesize topBarView;
@synthesize bottomBarView;
@synthesize textViewInput;
@synthesize buttonSend;
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChangeNotification:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.layer.masksToBounds = YES;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView beginAnimations:@"DDChatViewControllerKeyboardAnimation" context:nil];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    CGRect rect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat dh = rect.size.height - self.weakParentViewController.tabBarController.tabBar.frame.size.height;
    self.mainView.frame = CGRectMake(self.mainView.frame.origin.x, self.mainView.frame.origin.y-dh, self.mainView.frame.size.width, self.mainView.frame.size.height);
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:@"DDChatViewControllerKeyboardAnimation" context:nil];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    CGRect rect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat dh = rect.size.height - self.weakParentViewController.tabBarController.tabBar.frame.size.height;
    self.mainView.frame = CGRectMake(self.mainView.frame.origin.x, self.mainView.frame.origin.y+dh, self.mainView.frame.size.width, self.mainView.frame.size.height);
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [mainView release];
    [topBarView release];
    [bottomBarView release];
    [textViewInput release];
    [buttonSend release];
    [tableView release];
    [super dealloc];
}

#pragma mark -
#pragma mark IB

- (IBAction)sendTouched:(id)sender
{
    self.textViewInput.text = nil;
    [self.textViewInput resignFirstResponder];
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewTextDidChangeNotification:(NSNotification *)notification
{
    //check sender
    if ([notification object] != self.textViewInput)
        return;
    
    //save needed values
    CGSize sizeBefore = self.textViewInput.frame.size;
    CGSize sizeAfter = self.textViewInput.contentSize;
    
    //save maximal value
    CGFloat maximalHeight = self.bottomBarView.frame.origin.y + self.bottomBarView.frame.size.height - (self.topBarView.frame.origin.y + self.topBarView.frame.size.height) + self.mainView.frame.origin.y + 38;
    
    //check for maximal size
    sizeAfter = CGSizeMake(sizeAfter.width, MIN(sizeAfter.height, maximalHeight));
    
    //calculate frame change
    CGSize sizeChange = CGSizeMake(sizeAfter.width - sizeBefore.width, sizeAfter.height - sizeBefore.height);
    
    //change frame
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x - sizeChange.width, self.tableView.frame.origin.y - sizeChange.height, self.tableView.frame.size.width + sizeChange.width, self.tableView.frame.size.height + sizeChange.height);
    self.bottomBarView.frame = CGRectMake(self.bottomBarView.frame.origin.x - sizeChange.width, self.bottomBarView.frame.origin.y - sizeChange.height, bottomBarView.frame.size.width + sizeChange.width, bottomBarView.frame.size.height + sizeChange.height);
}

@end
