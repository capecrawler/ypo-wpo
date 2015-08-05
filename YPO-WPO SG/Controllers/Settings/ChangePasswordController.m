//
//  ChangePasswordController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/30/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "ChangePasswordController.h"
#import "YPOAPIClient.h"
#import "YPOUser.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface ChangePasswordController()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *assignPasswordTextField;

@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (assign, nonatomic) BOOL                      keyboardVisible;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end


@implementation ChangePasswordController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.oldPasswordTextField.delegate = self;
    self.oldPasswordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.assignPasswordTextField.delegate = self;
    self.assignPasswordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.confirmPasswordTextField.delegate = self;
    self.confirmPasswordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.submitButton addTarget:self action:@selector(submitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}


- (BOOL)submitButtonClicked {
    if (![self.oldPasswordTextField.text isNotEmpty]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Enter your old password.", nil) maskType:SVProgressHUDMaskTypeBlack];
    } else if (![self.assignPasswordTextField.text isNotEmpty]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Please enter your new password.", nil) maskType:SVProgressHUDMaskTypeBlack];
    } else if (![self.assignPasswordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"New password doesn't match.", nil) maskType:SVProgressHUDMaskTypeBlack];
    } else {
        [self changePassword:self.oldPasswordTextField.text withNew:self.confirmPasswordTextField.text];
        return YES;
    }
    return NO;
}


- (void)changePassword:(NSString *)oldPassword withNew:(NSString *)newPassword {
    [self.view endEditing:YES];
    NSDictionary *parameters = @{@"func":                   @"member.change.password",
                                 @"username":               [YPOUser currentUser].userName,
                                 @"password":               oldPassword,
                                 @"new_password":           newPassword,
                                 @"new_password_verify":    newPassword,
                                 };
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Saving...", nil) maskType:SVProgressHUDMaskTypeBlack];
    [[YPOAPIClient sharedClient] GET:YPOAPIPathPrefix parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject[@"status"] boolValue]) {
            self.oldPasswordTextField.text = @"";
            self.assignPasswordTextField.text = @"";
            self.confirmPasswordTextField.text = @"";
            [SVProgressHUD showSuccessWithStatus:responseObject[@"message"] maskType:SVProgressHUDMaskTypeBlack];
        } else {
            [SVProgressHUD showErrorWithStatus:responseObject[@"message"] maskType:SVProgressHUDMaskTypeBlack];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription maskType:SVProgressHUDMaskTypeBlack];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.oldPasswordTextField) {
        [self.assignPasswordTextField becomeFirstResponder];
        return NO;
    } else if (textField == self.assignPasswordTextField) {
        [self.confirmPasswordTextField becomeFirstResponder];
        return NO;
    } else {
        return [self submitButtonClicked];
    }
}


#pragma mark - Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    if (self.keyboardVisible) return;
    self.keyboardVisible = YES;
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets inset = self.scrollView.contentInset;
    inset.bottom += kbSize.height - 50;
    self.scrollView.contentInset = inset;
    self.scrollView.scrollIndicatorInsets = inset;    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (!self.keyboardVisible) return;
    self.keyboardVisible = NO;
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets inset = self.scrollView.contentInset;
    inset.bottom -= kbSize.height + 50;
    self.scrollView.contentInset = inset;
    self.scrollView.scrollIndicatorInsets = inset;
    
}


@end
