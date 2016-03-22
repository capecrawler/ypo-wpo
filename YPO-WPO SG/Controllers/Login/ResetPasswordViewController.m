//
//  ResetPasswordViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 29/02/2016.
//  Copyright © 2016 Raketeers. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "YPOAPIClient.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface ResetPasswordViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.emailTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetPassword:(NSString *)email {
    [self.view endEditing:YES];
    NSDictionary *parameters = @{@"func": @"member.send.password_reset",
                                 @"email": email,
                                 };
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [[YPOAPIClient sharedClient] GET:YPOAPIPathPrefix parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject[@"status"] boolValue]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [SVProgressHUD showSuccessWithStatus:responseObject[@"message"] maskType:SVProgressHUDMaskTypeBlack];
        } else {
            [SVProgressHUD showErrorWithStatus:responseObject[@"message"] maskType:SVProgressHUDMaskTypeBlack];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription maskType:SVProgressHUDMaskTypeBlack];
    }];
    
}

- (void)prepareEmailReset {
    if ([self.emailTextField.text isNotEmpty]) {
        [self resetPassword:self.emailTextField.text];
    }
}

- (IBAction)onSubmitButtonPressed:(id)sender {
    [self prepareEmailReset];
}


- (IBAction)onCancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self prepareEmailReset];
    return YES;
}


@end
