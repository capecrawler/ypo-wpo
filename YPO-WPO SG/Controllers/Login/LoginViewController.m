//
//  LoginViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/6/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "LoginViewController.h"
#import "YPOAPIClient.h"
#import "AppDelegate.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "CCLoginBackgroundView.h"
#import "YPOUser.h"

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView             *LoginFormView;
@property (weak, nonatomic) IBOutlet UIImageView        *logoView;
@property (weak, nonatomic) IBOutlet UITextField        *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField        *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton           *loginButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginFormTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forgotPasswordBottomConstraint;

@property (assign, nonatomic) BOOL                      keyboardVisible;
@property (strong, nonatomic) CCLoginBackgroundView     *backgroundSlideShow;

@end

@implementation LoginViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - LifeCycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userIdTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.backgroundSlideShow = [[CCLoginBackgroundView alloc] initWithFrame:self.view.bounds];
    self.backgroundSlideShow.images = @[ [UIImage imageNamed:@"1.jpg"], [UIImage imageNamed:@"2.jpg"], [UIImage imageNamed:@"3.jpg"], [UIImage imageNamed:@"4.jpg"]];
    self.backgroundSlideShow.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.backgroundSlideShow.contentMode = UIViewContentModeScaleAspectFill;
    [self.backgroundSlideShow startSlideShow];
    [self.view insertSubview:self.backgroundSlideShow atIndex:0];

    
    self.userIdTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    [self.loginButton addTarget:self action:@selector(executeLogin) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    [self.backgroundSlideShow invalidateSlideShow];
}

#pragma mark - Private Methods

- (void)endEditing {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userIdTextField){
        [self.passwordTextField becomeFirstResponder];
        return NO;
    }else if (textField == self.passwordTextField){
        [self executeLogin];
    }
    return YES;
}


#pragma mark - Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    if (self.keyboardVisible) return;
    self.keyboardVisible = YES;
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.forgotPasswordBottomConstraint.constant += kbSize.height;
    self.loginFormTopConstraint.constant -= 180;
    [UIView animateWithDuration:0.4 animations:^{
        self.logoView.alpha = 0;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (!self.keyboardVisible) return;
    self.keyboardVisible = NO;
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.forgotPasswordBottomConstraint.constant -= kbSize.height;

    self.loginFormTopConstraint.constant += 180;
    [UIView animateWithDuration:0.4 animations:^{
        self.logoView.alpha = 1;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardFrameDidChange:(NSNotification *) notification {
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardBeginFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    CGFloat offset = keyboardBeginFrame.size.height - keyboardEndFrame.size.height;
    
    self.forgotPasswordBottomConstraint.constant -= offset;
    [UIView animateWithDuration:0.1 animations:^{
        [self.view layoutIfNeeded];
    }];
}


- (void)executeLogin {
    if ([self.userIdTextField.text isNotEmpty] && [self.passwordTextField.text isNotEmpty]) {
        [self.view endEditing:YES];
        NSDictionary *param = @{@"username" : self.userIdTextField.text,
                                @"password" : self.passwordTextField.text,
                                @"func" : @"member.authenticate"};
        [SVProgressHUD showWithStatus:@"Logging in..." maskType:SVProgressHUDMaskTypeBlack];
        [[YPOAPIClient sharedClient] GET:@"/api/v1/" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([responseObject[@"status"] boolValue]) {
                [SVProgressHUD dismiss];
//                NSDictionary *data = responseObject[@"data"];
//                NSString *memberID = data[@"member_id"];
//                [[NSUserDefaults standardUserDefaults] setObject:memberID forKey:@"memberID"];
                YPOUser *user = [YPOUser MR_createEntity];
                [user parseDictionary:responseObject[@"data"]];
                [YPOUser setCurrentUser:user];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                [appDelegate showLogin:NO];
            } else {
                [SVProgressHUD showErrorWithStatus:responseObject[@"message"] maskType:SVProgressHUDMaskTypeBlack];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription maskType:SVProgressHUDMaskTypeBlack];
        }];
    }
}



@end
