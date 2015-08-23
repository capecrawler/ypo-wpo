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


@interface EditProfileViewController()

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


@end


@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupFields];
}


#pragma mark - UIHelpers

- (JVFloatLabeledTextField *)createTextFieldWithPlaceHolder:(NSString *)placeHolder {
    JVFloatLabeledTextField *textField = [[JVFloatLabeledTextField alloc] init];
    textField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:NSLocalizedString(placeHolder, @"")
                                    attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    textField.floatingLabelFont = [UIFont boldSystemFontOfSize:11];
    textField.floatingLabelTextColor = [UIColor lightGrayColor];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    return textField;
}


- (JVFloatLabeledTextView *)createTextViewWithPlaceHolder:(NSString *)placeHolder {
    JVFloatLabeledTextView *textView = [[JVFloatLabeledTextView alloc] init];
    textView.placeholder = NSLocalizedString(placeHolder, @"");
    textView.floatingLabelFont = [UIFont boldSystemFontOfSize:11];
    textView.floatingLabelTextColor = [UIColor lightGrayColor];
    textView.scrollEnabled = NO;
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
    
    NSDictionary *viewDictionary = @{
                                     @"scrollView":self.scrollView,
                                     @"contentView": self.contentView,
                                     @"firstNameTextField" : self.firstNameTextField,
                                     @"lastNameTextField" : self.lastNameTextField,
                                     @"middleNameTextField" : self.middleNameTextField,
                                     @"preferredNameTextField" : self.preferredNameTextField,
                                     @"chapterNameLabel" : self.chapterNameLabel,
                                     @"chapterJoinedDateLabel" : self.chapterJoinedDateLabel,
                                     @"genderLabel" : self.genderLabel,
                                     @"birthdateLabel" : self.birthdateLabel,
                                     @"emailTextField" : self.emailTextField,
                                     @"mobileNumberTextField" : self.mobileNumberTextField,
                                     @"contactNoBusinessTextField" : self.contactNoBusinessTextField,
                                     @"contactNoHomeTextField" : self.contactNoHomeTextField,
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
                                     @"flexibleFooter" : flexibleFooter,
                                     };
    NSDictionary *metrics = @{@"minHeight" : @(40)
                              };
    
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView(==scrollView)]|" options:0 metrics:nil views:viewDictionary]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
        
    
    [self.contentView addSubview:self.firstNameTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[firstNameTextField]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[firstNameTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    

    [self.contentView addSubview:self.lastNameTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[lastNameTextField]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[firstNameTextField]-[lastNameTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    
    [self.contentView addSubview:self.middleNameTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[middleNameTextField]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastNameTextField]-[middleNameTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.preferredNameTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[preferredNameTextField]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[middleNameTextField]-[preferredNameTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.chapterNameLabel];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[chapterNameLabel]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[preferredNameTextField]-[chapterNameLabel(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.chapterJoinedDateLabel];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[chapterJoinedDateLabel]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[chapterNameLabel]-[chapterJoinedDateLabel(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.genderLabel];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[genderLabel]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[chapterJoinedDateLabel]-[genderLabel(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.birthdateLabel];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[birthdateLabel]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[genderLabel]-[birthdateLabel(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.emailTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[emailTextField]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[birthdateLabel]-[emailTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.mobileNumberTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[mobileNumberTextField]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[emailTextField]-[mobileNumberTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.contactNoBusinessTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[contactNoBusinessTextField]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[mobileNumberTextField]-[contactNoBusinessTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.contactNoHomeTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[contactNoHomeTextField]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[contactNoBusinessTextField]-[contactNoHomeTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];


    [self.contentView addSubview:self.companyTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[companyTextField]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[contactNoHomeTextField]-[companyTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
                 
    [self.contentView addSubview:self.companyBusinessTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[companyBusinessTextField]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[companyTextField]-[companyBusinessTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.companyPositionTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[companyPositionTextField]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[companyBusinessTextField]-[companyPositionTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    

    [self.contentView addSubview:self.companyAddress1TextView];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[companyAddress1TextView]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[companyPositionTextField]-[companyAddress1TextView(>=minHeight)]" options:0 metrics:metrics views:viewDictionary]];

    
    [self.contentView addSubview:self.companyAddress2TextView];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[companyAddress2TextView]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[companyAddress1TextView]-[companyAddress2TextView(>=minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    

     
    [self.contentView addSubview:self.cityTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[cityTextField]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[companyAddress2TextView]-[cityTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.provinceTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[provinceTextField]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cityTextField]-[provinceTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.countryLabel];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[countryLabel]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[provinceTextField]-[countryLabel(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.zipCodeTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[zipCodeTextField]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[countryLabel]-[zipCodeTextField(minHeight)]" options:0 metrics:metrics views:viewDictionary]];
    
    [self.contentView addSubview:self.websiteTextField];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[websiteTextField]-|" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[zipCodeTextField]-[websiteTextField(minHeight)]-|" options:0 metrics:metrics views:viewDictionary]];

}


#pragma mark - Properties

- (JVFloatLabeledTextField *)firstNameTextField {
    if (_firstNameTextField == nil) {
        _firstNameTextField = [self createTextFieldWithPlaceHolder:@"First Name"];
        _firstNameTextField.text = [YPOUser currentUser]
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
