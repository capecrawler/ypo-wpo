//
//  EditProfileViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/20/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "EditProfileViewController.h"
#import "YPOUser.h"
#import <JVFloatLabeledTextField/JVFloatLabeledTextView.h>
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>
#import "YPOMember.h"
#import "YPOMemberDetails.h"
#import "YPOChapter.h"
#import "YPOContactDetails.h"
#import "YPOCompany.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "YPOAPIClient.h"
#import "YPOGenderController.h"
#import "YPODateController.h"
#import "YPOChapter.h"
#import "YPOChapterController.h"


typedef NS_ENUM(NSInteger, ProfileField) {
    ProfileFieldFirstName,
    ProfileFieldLastName,
    ProfileFieldMiddleName,
    ProfileFieldPreferredName,
    ProfileFieldChapterName,
    ProfileFieldChapterJoinedDate,
    ProfileFieldGender,
    ProfileFieldBirthDate,
    ProfileFieldEmail,
    ProfileFieldMobileNumber,
    ProfileFieldContactNoBusiness,
    ProfileFieldContactNoHome,
    ProfileFieldPassion,
    ProfileFieldCompany,
    ProfileFieldCompanyBusiness,
    ProfileFieldCompanyPosition,
    ProfileFieldCompanyAddress1,
    ProfileFieldCompanyAddress2,
    ProfileFieldCity,
    ProfileFieldProvince,
    ProfileFieldCountry,
    ProfileFieldZipCode,
    ProfileFieldWebsite
};


@interface EditProfileViewController()<UITextFieldDelegate, UITextViewDelegate, YPODateControllerDelegate, YPOGenderControllerDelegate, YPOChapterControllerDelegate>

@property (nonatomic, strong) JVFloatLabeledTextField *firstNameTextField;
@property (nonatomic, strong) JVFloatLabeledTextField *lastNameTextField;
@property (nonatomic, strong) JVFloatLabeledTextField *middleNameTextField;
@property (nonatomic, strong) JVFloatLabeledTextField *preferredNameTextField;
@property (nonatomic, strong) JVFloatLabeledTextField *chapterNameLabel;
@property (nonatomic, strong) JVFloatLabeledTextField *chapterJoinedDateLabel;
@property (nonatomic, strong) JVFloatLabeledTextField *genderLabel;
@property (nonatomic, strong) JVFloatLabeledTextField *birthdateLabel;
@property (nonatomic, strong) JVFloatLabeledTextField *emailTextField;
@property (nonatomic, strong) JVFloatLabeledTextField *mobileNumberTextField;
@property (nonatomic, strong) JVFloatLabeledTextField *contactNoBusinessTextField;
@property (nonatomic, strong) JVFloatLabeledTextField *contactNoHomeTextField;
@property (nonatomic, strong) JVFloatLabeledTextView  *passionTextView;
@property (nonatomic, strong) JVFloatLabeledTextField *companyTextField;
@property (nonatomic, strong) JVFloatLabeledTextField *companyBusinessTextField;
@property (nonatomic, strong) JVFloatLabeledTextField *companyPositionTextField;
@property (nonatomic, strong) JVFloatLabeledTextView *companyAddress1TextView;
@property (nonatomic, strong) JVFloatLabeledTextView *companyAddress2TextView;
@property (nonatomic, strong) JVFloatLabeledTextField *cityTextField;
@property (nonatomic, strong) JVFloatLabeledTextField *provinceTextField;
@property (nonatomic, strong) JVFloatLabeledTextField *countryLabel;
@property (nonatomic, strong) JVFloatLabeledTextField *zipCodeTextField;
@property (nonatomic, strong) JVFloatLabeledTextField *websiteTextField;

@property (nonatomic, strong) NSArray *profileFields;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) YPOMember *member;
@property (assign, nonatomic) BOOL keyboardVisible;
@property (nonatomic, assign) UIEdgeInsets scrollViewInset;
@property (nonatomic, strong) YPOChapter *chapter;
@end


@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupFields];
    [self fetchMemberDetails];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewWillDisappear:(BOOL)animated {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}


- (void)keyboardWillShow:(NSNotification *)notification {
    if (self.keyboardVisible) return;
    self.keyboardVisible = YES;
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.scrollViewInset = self.scrollView.contentInset;
    UIEdgeInsets inset = self.scrollView.contentInset;
    inset.bottom = kbSize.height;
    self.scrollView.contentInset = inset;
    self.scrollView.scrollIndicatorInsets = inset;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (!self.keyboardVisible) return;
    self.keyboardVisible = NO;
    self.scrollView.contentInset = self.scrollViewInset;
    self.scrollView.scrollIndicatorInsets = self.scrollViewInset;
}


#pragma mark - Load Data

- (void)loadData {
    YPOMemberDetailsRequest *request = (YPOMemberDetailsRequest *)[YPOMemberDetails constructRequest];
    request.memberID = [YPOUser currentUser].memberID;
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        [self fetchMemberDetails];
        [YPOUser currentUser].name = self.member.name;
        [YPOUser currentUser].email = self.member.contactDetails.email;
        [YPOUser currentUser].profilePictureURL = self.member.profilePicURL;
    } failure:nil];
}

- (void)fetchMemberDetails{
    self.chapter = self.member.chapterOrg;
    
    self.firstNameTextField.text = self.member.firstName;
    self.lastNameTextField.text = self.member.lastName;
    self.middleNameTextField.text = self.member.middleName;
    self.preferredNameTextField.text = self.member.nickname;
    self.chapterNameLabel.text = self.chapter.name;
    self.chapterJoinedDateLabel.text = [self.member joinedDateFormatted];
    self.genderLabel.text = [self.member genderLabel];
    self.birthdateLabel.text = [self.member birthdateFormatted];
    self.emailTextField.text = self.member.contactDetails.email;
    self.mobileNumberTextField.text = self.member.contactDetails.mobile;
    self.contactNoBusinessTextField.text = self.member.contactDetails.business;
    self.contactNoHomeTextField.text = self.member.contactDetails.home;
    self.passionTextView.text = self.member.passion;
    self.companyTextField.text = self.member.company.name;
    self.companyBusinessTextField.text = self.member.company.business;
    self.companyPositionTextField.text = self.member.company.position;
    self.companyAddress1TextView.text = self.member.company.address1;
    self.companyAddress2TextView.text = self.member.company.address2;
    self.cityTextField.text = self.member.company.city;
    self.provinceTextField.text = self.member.company.province;
    self.countryLabel.text = self.member.company.country;
    self.zipCodeTextField.text = self.member.company.zip;
    self.websiteTextField.text = self.member.company.website;
    

}

- (IBAction)saveProfile:(id)sender {
    [self.view endEditing:YES];

    NSDate *chapterJoinedDate = [NSDate dateFromString:self.chapterJoinedDateLabel.text format:@"dd MMMM yyyy"];
    NSDate *birthdate         = [NSDate dateFromString:self.birthdateLabel.text format:@"dd MMMM yyyy"];
    NSString *gender;
    NSString *genderInputLowerCase = [self.genderLabel.text lowercaseString];
    if ([genderInputLowerCase isEqual:@"male"]) {
        gender = @"M";
    } else if ([genderInputLowerCase isEqual:@"female"]) {
        gender = @"F";
    } else {
        gender = @"";
    }
    
    NSDictionary *parameters = @{
                                 @"func": @"member.update.profile",
                                 @"member_id": [YPOUser currentUser].memberID,
                                 @"first_name": self.firstNameTextField.text,
                                 @"last_name": self.lastNameTextField.text,
                                 @"middle_name": self.middleNameTextField.text,
                                 @"preferred_name": self.preferredNameTextField.text,
                                 @"chapter_id": self.chapter.chapterID,
                                 @"chapter_joined": [chapterJoinedDate stringWithFormat:@"yyyy-MM-dd"], // yyyy-MM-dd
                                 @"gender": gender, // M:F
                                 @"birth_date": [birthdate stringWithFormat:@"yyyy-MM-dd"], // yyyy-MM-dd
                                 @"email": self.emailTextField.text,
                                 @"mobile_number": self.mobileNumberTextField.text,
                                 @"passion": self.passionTextView.text,
                                 @"contact_no_business": self.contactNoBusinessTextField.text,
                                 @"contact_no_home": self.contactNoHomeTextField.text,
                                 @"company": self.companyTextField.text,
                                 @"company_business": self.companyBusinessTextField.text,
                                 @"company_position": self.companyPositionTextField.text,
                                 @"company_address1": self.companyAddress1TextView.text,
                                 @"company_address2": self.companyAddress2TextView.text,
                                 @"company_city": self.cityTextField.text,
                                 @"company_province": self.provinceTextField.text,
                                 @"company_country_id": @"1",
                                 @"company_zip_code": self.zipCodeTextField.text,
                                 @"company_website": self.websiteTextField.text,
                                 };
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Saving...", nil) maskType:SVProgressHUDMaskTypeBlack];
    [[YPOAPIClient sharedClient]GET:YPOAPIPathPrefix parameters:parameters success:^(NSURLSessionDataTask * task, id responseObject) {
        if ([responseObject[@"status"] boolValue]) {
            [SVProgressHUD showSuccessWithStatus:responseObject[@"message"] maskType:SVProgressHUDMaskTypeBlack];
        } else {
            [SVProgressHUD showErrorWithStatus:responseObject[@"message"] maskType:SVProgressHUDMaskTypeBlack];
        }
    } failure:^(NSURLSessionDataTask * task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription maskType:SVProgressHUDMaskTypeBlack];
    }];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.genderLabel) {
        YPOGenderController *controller = [[YPOGenderController alloc] init];
        controller.genderDelegate = self;
        [controller presentPopoverFromRect:textField.bounds inView:textField];
        return NO;
    } else if (textField == self.birthdateLabel) {
        NSDate *date = [NSDate dateFromString:self.birthdateLabel.text format:@"dd MMMM yyyy"];
        YPODateController *controller = [[YPODateController alloc] initWithSelectedDate:date];
        controller.tag = ProfileFieldBirthDate;
        controller.delegate = self;
        [controller show];
        return NO;
    } else if (textField == self.chapterNameLabel) {
        YPOChapterController *controller = [[YPOChapterController alloc] init];
        controller.chapterDelegate = self;
        [controller presentPopoverFromRect:textField.bounds inView:textField];
        return NO;
    } else if (textField == self.chapterJoinedDateLabel) {
        NSDate *date = [NSDate dateFromString:self.chapterJoinedDateLabel.text format:@"dd MMMM yyyy"];
        YPODateController *controller = [[YPODateController alloc] initWithSelectedDate:date];
        controller.tag = ProfileFieldChapterJoinedDate;
        controller.delegate = self;
        [controller show];
        return NO;
    }
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UITextViewDelegate



#pragma mark - YPOGenderControllerDelegate

- (void)genderController:(YPOGenderController *)controller didSelectGender:(NSString *)gender {
    self.genderLabel.text = gender;
}


#pragma mark - YPOChapterControllerDelegate

- (void)chapterController:(YPOChapterController *)controller didSelectChapter:(YPOChapter *)chapter {
    self.chapter = chapter;
    self.chapterNameLabel.text = self.chapter.name;
}


#pragma mark - YPODateControllerDelegate

- (void)dateController:(YPODateController *)controller dateSelected:(NSDate*)date {
    if (controller.tag == ProfileFieldBirthDate) {
        self.birthdateLabel.text = [date stringWithFormat:@"dd MMMM yyyy"];
    } else if (controller.tag == ProfileFieldChapterJoinedDate) {
        self.chapterJoinedDateLabel.text = [date stringWithFormat:@"dd MMMM yyyy"];
    }
}


#pragma mark - UIHelpers

- (JVFloatLabeledTextField *)createTextFieldWithPlaceHolder:(NSString *)placeHolder {
    JVFloatLabeledTextField *textField = [[JVFloatLabeledTextField alloc] init];
    textField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:NSLocalizedString(placeHolder, @"")
                                    attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    textField.floatingLabelFont = [UIFont boldSystemFontOfSize:11];
    textField.floatingLabelTextColor = [UIColor lightGrayColor];
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyDone;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    return textField;
}


- (JVFloatLabeledTextView *)createTextViewWithPlaceHolder:(NSString *)placeHolder {
    JVFloatLabeledTextView *textView = [[JVFloatLabeledTextView alloc] init];
    textView.placeholder = NSLocalizedString(placeHolder, @"");
    textView.placeholderTextColor = [UIColor darkGrayColor];
    textView.floatingLabelFont = [UIFont boldSystemFontOfSize:11];
    textView.floatingLabelTextColor = [UIColor lightGrayColor];
    textView.scrollEnabled = NO;
    textView.delegate = self;
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    return textView;
}


- (void)setupFields {
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];
    
    UIView *flexibleFooter = [[UIView alloc] init];
    flexibleFooter.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    UILabel *chapterSectionLabel = [[UILabel alloc] init];
    chapterSectionLabel.text = @"Chapter Information";
    chapterSectionLabel.font = [UIFont boldSystemFontOfSize:20];
    chapterSectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *employmentSectionLabel = [[UILabel alloc] init];
    employmentSectionLabel.text = @"Employment Information";
    employmentSectionLabel.font = [UIFont boldSystemFontOfSize:20];
    employmentSectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *viewDictionary = @{
                                     @"scrollView":self.scrollView,
                                     @"contentView": self.contentView,
                                     @"firstNameTextField" : self.firstNameTextField,
                                     @"lastNameTextField" : self.lastNameTextField,
                                     @"middleNameTextField" : self.middleNameTextField,
                                     @"preferredNameTextField" : self.preferredNameTextField,
                                     @"genderLabel" : self.genderLabel,
                                     @"birthdateLabel" : self.birthdateLabel,
                                     @"emailTextField" : self.emailTextField,
                                     @"mobileNumberTextField" : self.mobileNumberTextField,
                                     @"contactNoBusinessTextField" : self.contactNoBusinessTextField,
                                     @"contactNoHomeTextField" : self.contactNoHomeTextField,
                                     @"passionTextView": self.passionTextView,
                                     @"chapterSectionLabel" : chapterSectionLabel,
                                     @"chapterNameLabel" : self.chapterNameLabel,
                                     @"chapterJoinedDateLabel" : self.chapterJoinedDateLabel,
                                     @"employmentSectionLabel" : employmentSectionLabel,
                                     @"companyTextField" : self.companyTextField,
                                     @"companyBusinessTextField" : self.companyBusinessTextField,
                                     @"companyPositionTextField" : self.companyPositionTextField,
                                     @"companyAddress1TextView" : self.companyAddress1TextView,
                                     @"companyAddress2TextView" : self.companyAddress2TextView,
                                     @"cityTextField" : self.cityTextField,
                                     @"provinceTextField" : self.provinceTextField,
                                     @"countryLabel" : self.countryLabel,
                                     @"zipCodeTextField" : self.zipCodeTextField,
                                     @"websiteTextField" : self.websiteTextField,
                                     };
    NSDictionary *metrics = @{@"minHeight" : @(40),
                              @"margin": @(16),
                              };
    
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView(==scrollView)]|" options:0 metrics:nil views:viewDictionary]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.contentView addSubview:self.firstNameTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[firstNameTextField]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[firstNameTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    

    [self.contentView addSubview:self.lastNameTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[lastNameTextField]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[firstNameTextField]-margin-[lastNameTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    
    [self.contentView addSubview:self.middleNameTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[middleNameTextField]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastNameTextField]-margin-[middleNameTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.preferredNameTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[preferredNameTextField]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[middleNameTextField]-margin-[preferredNameTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.genderLabel];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[genderLabel]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[preferredNameTextField]-margin-[genderLabel(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.birthdateLabel];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[birthdateLabel]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[genderLabel]-margin-[birthdateLabel(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.emailTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[emailTextField]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[birthdateLabel]-margin-[emailTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.mobileNumberTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[mobileNumberTextField]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[emailTextField]-margin-[mobileNumberTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.contactNoBusinessTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[contactNoBusinessTextField]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[mobileNumberTextField]-margin-[contactNoBusinessTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.contactNoHomeTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[contactNoHomeTextField]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[contactNoBusinessTextField]-margin-[contactNoHomeTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.passionTextView];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[passionTextView]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[contactNoHomeTextField]-margin-[passionTextView(>=minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    

    [self.contentView addSubview:chapterSectionLabel];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[chapterSectionLabel]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[passionTextView]-margin-[chapterSectionLabel]" options:0 metrics:metrics views:viewDictionary]];
    
    
    [self.contentView addSubview:self.chapterNameLabel];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[chapterNameLabel]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[chapterSectionLabel]-margin-[chapterNameLabel(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.chapterJoinedDateLabel];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[chapterJoinedDateLabel]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[chapterNameLabel]-margin-[chapterJoinedDateLabel(minHeight)]" options:0 metrics:metrics views:viewDictionary]];

    [self.contentView addSubview:employmentSectionLabel];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[employmentSectionLabel]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[chapterJoinedDateLabel]-margin-[employmentSectionLabel(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    

    [self.contentView addSubview:self.companyTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[companyTextField]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[employmentSectionLabel]-margin-[companyTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
                 
    [self.contentView addSubview:self.companyBusinessTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[companyBusinessTextField]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[companyTextField]-margin-[companyBusinessTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.companyPositionTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[companyPositionTextField]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[companyBusinessTextField]-margin-[companyPositionTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    

    [self.contentView addSubview:self.companyAddress1TextView];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[companyAddress1TextView]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[companyPositionTextField]-margin-[companyAddress1TextView(>=minHeight)]" options:0 metrics:metrics views:viewDictionary]];

    
    [self.contentView addSubview:self.companyAddress2TextView];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[companyAddress2TextView]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[companyAddress1TextView]-margin-[companyAddress2TextView(>=minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    

     
    [self.contentView addSubview:self.cityTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[cityTextField]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[companyAddress2TextView]-margin-[cityTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.provinceTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[provinceTextField]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cityTextField]-margin-[provinceTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.countryLabel];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[countryLabel]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[provinceTextField]-margin-[countryLabel(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.zipCodeTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[zipCodeTextField]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[countryLabel]-margin-[zipCodeTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.websiteTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[websiteTextField]-margin-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[zipCodeTextField]-margin-[websiteTextField(minHeight)]-margin-|" options:0 metrics:metrics views:viewDictionary]];

}


#pragma mark - Properties

- (YPOMember *)member {
    if (_member == nil) {
        _member = [YPOMember MR_findFirstByAttribute:@"memberID" withValue:[YPOUser currentUser].memberID];
    }
    return _member;
}

- (JVFloatLabeledTextField *)firstNameTextField {
    if (_firstNameTextField == nil) {
        _firstNameTextField = [self createTextFieldWithPlaceHolder:@"First Name"];
    }
    return _firstNameTextField;
}


- (JVFloatLabeledTextField *)lastNameTextField {
    if (_lastNameTextField == nil) {
        _lastNameTextField = [self createTextFieldWithPlaceHolder:@"Last Name"];
    }
    return _lastNameTextField;
}


- (JVFloatLabeledTextField *)middleNameTextField {
    if (_middleNameTextField == nil) {
        _middleNameTextField = [self createTextFieldWithPlaceHolder:@"Middle Name"];
    }
    return _middleNameTextField;
}


- (JVFloatLabeledTextField *)preferredNameTextField {
    if (_preferredNameTextField == nil) {
        _preferredNameTextField = [self createTextFieldWithPlaceHolder:@"Preferred Name"];
    }
    return _preferredNameTextField;
}


- (JVFloatLabeledTextField *)chapterNameLabel {
    if (_chapterNameLabel == nil) {
        _chapterNameLabel = [self createTextFieldWithPlaceHolder:@"Chapter"];
    }
    return _chapterNameLabel;
}


- (JVFloatLabeledTextField *)chapterJoinedDateLabel {
    if (_chapterJoinedDateLabel == nil) {
        _chapterJoinedDateLabel = [self createTextFieldWithPlaceHolder:@"Joined Date"];
    }
    return _chapterJoinedDateLabel;
}


- (JVFloatLabeledTextField *)genderLabel {
    if (_genderLabel == nil) {
        _genderLabel = [self createTextFieldWithPlaceHolder:@"Gender"];
    }
    return _genderLabel;
}


- (JVFloatLabeledTextField *)birthdateLabel {
    if (_birthdateLabel == nil) {
        _birthdateLabel = [self createTextFieldWithPlaceHolder:@"Birth Date"];
    }
    return _birthdateLabel;
}


- (JVFloatLabeledTextField *)emailTextField {
    if (_emailTextField == nil) {
        _emailTextField = [self createTextFieldWithPlaceHolder:@"Email"];
    }
    return _emailTextField;
}


- (JVFloatLabeledTextField *)mobileNumberTextField {
    if (_mobileNumberTextField == nil) {
        _mobileNumberTextField = [self createTextFieldWithPlaceHolder:@"Mobile No"];
    }
    return _mobileNumberTextField;
}


- (JVFloatLabeledTextField *)contactNoBusinessTextField {
    if (_contactNoBusinessTextField == nil) {
        _contactNoBusinessTextField = [self createTextFieldWithPlaceHolder:@"Business No"];
    }
    return _contactNoBusinessTextField;
}


- (JVFloatLabeledTextField *)contactNoHomeTextField {
    if (_contactNoHomeTextField == nil) {
        _contactNoHomeTextField = [self createTextFieldWithPlaceHolder:@"Home No"];
    }
    return _contactNoHomeTextField;
}


- (JVFloatLabeledTextView *)passionTextView {
    if (_passionTextView == nil) {
        _passionTextView = [self createTextViewWithPlaceHolder:@"Passion"];
    }
    return _passionTextView;
}


- (JVFloatLabeledTextField *)companyTextField {
    if (_companyTextField == nil) {
        _companyTextField = [self createTextFieldWithPlaceHolder:@"Company Name"];
    }
    return _companyTextField;
}


- (JVFloatLabeledTextField *)companyBusinessTextField {
    if (_companyBusinessTextField == nil) {
        _companyBusinessTextField = [self createTextFieldWithPlaceHolder:@"Company Business"];
    }
    return _companyBusinessTextField;
}


- (JVFloatLabeledTextField *)companyPositionTextField {
    if (_companyPositionTextField == nil) {
        _companyPositionTextField = [self createTextFieldWithPlaceHolder:@"Position"];
    }
    return _companyPositionTextField;
}


- (JVFloatLabeledTextView *)companyAddress1TextView {
    if (_companyAddress1TextView == nil) {
        _companyAddress1TextView = [self createTextViewWithPlaceHolder:@"Company Address1"];
    }
    return _companyAddress1TextView;
}


- (JVFloatLabeledTextView *)companyAddress2TextView {
    if (_companyAddress2TextView == nil) {
        _companyAddress2TextView = [self createTextViewWithPlaceHolder:@"Company Address2"];
    }
    return _companyAddress2TextView;
}


- (JVFloatLabeledTextField *)cityTextField {
    if (_cityTextField == nil) {
        _cityTextField = [self createTextFieldWithPlaceHolder:@"City"];
    }
    return _cityTextField;
}


- (JVFloatLabeledTextField *)provinceTextField {
    if (_provinceTextField == nil) {
        _provinceTextField = [self createTextFieldWithPlaceHolder:@"Province"];
    }
    return _provinceTextField;
}


- (JVFloatLabeledTextField *)countryLabel {
    if (_countryLabel == nil) {
        _countryLabel = [self createTextFieldWithPlaceHolder:@"Country"];
    }
    return _countryLabel;
}


- (JVFloatLabeledTextField *)zipCodeTextField {
    if (_zipCodeTextField == nil) {
        _zipCodeTextField = [self createTextFieldWithPlaceHolder:@"Zip Code"];
    }
    return _zipCodeTextField;
}


- (JVFloatLabeledTextField *)websiteTextField {
    if (_websiteTextField == nil) {
        _websiteTextField = [self createTextFieldWithPlaceHolder:@"Website"];
    }
    return _websiteTextField;
}


@end
