//
//  LoginViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/6/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *LoginFormView;
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginFormTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forgotPasswordBottomConstraint;
@property (assign, nonatomic) BOOL keyboardVisible;

@end

@implementation LoginViewController

#pragma mark - LifeCycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    
}

#pragma mark - Private Methods

- (void) endEditing{
    [self.view endEditing:YES];
}



#pragma mark - Notification

- (void)keyboardWillShow: (NSNotification *) notification{
    if (self.keyboardVisible) return;
    self.keyboardVisible = YES;
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.forgotPasswordBottomConstraint.constant += kbSize.height;
    self.loginFormTopConstraint.constant -= 180;
    [UIView animateWithDuration:0.4 animations:^{
        self.logoView.alpha = 0;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide: (NSNotification *) notification{
    if (!self.keyboardVisible) return;
    self.keyboardVisible = NO;
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.forgotPasswordBottomConstraint.constant -= kbSize.height;

    self.loginFormTopConstraint.constant += 180;
    [UIView animateWithDuration:0.4 animations:^{
        self.logoView.alpha = 1;
        [self.view layoutIfNeeded];
    }];
    
}

- (void)keyboardFrameDidChange:(NSNotification *) notification{
    
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardBeginFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    CGFloat offset = keyboardBeginFrame.size.height - keyboardEndFrame.size.height;
    
    self.forgotPasswordBottomConstraint.constant -= offset;
    [UIView animateWithDuration:0.1 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    
}


@end
